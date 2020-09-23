macroScript UE4CamExporter
category:"ExportTools" 
tooltip:"UE4 Camera Exporter"
Icon:#("Cameras",3)

(
	rollout Exporter "KidsReturn's UE4CamExporter" width:256
	(
        -- 清除缓存
        global sourceCam = undefined

        -- 记录帧范围
		local oriStart = AnimationRange.start
		local oriEnd = AnimationRange.end
		local curStart = AnimationRange.start
		local curEnd = AnimationRange.end

		-- UI布局
		bitmap image1 fileName:(getdir #maxroot + "MacroScripts\logo.png")
		label label1 "警告！使用工具前请保存" offset:[0,10]
		button pickBtn "1.选择摄像机" offset:[0,10]
		label placeholder1 ""
        group "2.选择导出范围" 
        ( 
            spinner frameStart width:70 offset:[-4,0] range:[0, oriEnd, oriStart] type:#integer across:2
            spinner frameEnd "~" width:70 offset:[4,0] range:[0, oriEnd, oriEnd] type:#integer align:#left
        )
        label placeholder2 ""
		radiobuttons langBtn columns:2 labels:#("English", "中文")
		label placeholder3 ""
        button executeBtn "3.生成UE4摄像机"
        label placeholder4 ""
        group "偏移" 
        (
            spinner offsetX "X:" width:70 range:[-1000000, 1000000, 0] type:#integer align:#center across:3
            spinner offsetY "Y:" width:70 range:[-1000000, 1000000, 0] type:#integer align:#center
            spinner offsetZ "Z:" width:70 range:[-1000000, 1000000, 0] type:#integer align:#center
        )
        group "旋转" 
        ( 
            spinner yaw "Yaw:" width:70 range:[-180, 180, 90] type:#integer align:#center
        )

        -- UI事件
        on pickBtn pressed do               -- 选择摄像机按钮
		(
			fn camFilter obj = isKindOf obj Camera      -- 筛选方法
			global sourceCam = selectByName title:"选择摄像机" buttonText:"确定" filter:camFilter showHidden:true single:true
            if sourceCam != undefined then
            (
                pickBtn.text = sourceCam.name
            )
		)

		on frameStart changed val do        -- 帧开始
		(
			curStart = frameStart.value
			if curStart < curEnd then
			(
				AnimationRange = interval curStart curEnd
			)
		)
			
		on frameEnd changed val do          -- 帧结束
		(
			curEnd = frameEnd.value
			if curStart < curEnd then
			(
				AnimationRange = interval curStart curEnd
			)
		)
			
		on executeBtn pressed do            -- 生成UE4摄像机
		(
			if sourceCam != undefined then
			(
				local wireExpr = if langBtn.state == 2 then "视野" else "FOV"
                -- 位置约束
				local posCtrl = Position_Constraint()
                local posCstr = posCtrl.constraints
                posCstr.appendTarget sourceCam 100
                -- 朝向约束
				local rotCtrl = Orientation_Constraint()
                local rotCstr = rotCtrl.constraints
				rotCstr.appendTarget sourceCam 100	
                -- 不能直接复制sourceCam 这里生成一个自由相机 拷贝绝对位置
                local freeSourceCam = Freecamera isSelected:on
				freeSourceCam.name = sourceCam.name + "_Free"
				freeSourceCam.pos.controller = posCtrl
				freeSourceCam.rotation.controller = rotCtrl
				paramWire.connect sourceCam.baseObject[#FOV] freeSourceCam.baseObject[#FOV] wireExpr
				-- 烘培freeSourceCam
				local base = $All_Root
				select freeSourceCam
				for obj in selection do 
				(
					temp = Point()
					for t = curStart to curEnd do 
					(
						with animate on at time t
                        (
                            temp.transform = obj.transform
							if base != undefined then
							(
								temp.pos = obj.pos - base.pos
							)
                        )
					)
					obj.transform.controller = temp.transform.controller
					delete temp
				)
				
				-- 生成根节点 模拟骨骼根节点
				local dummyRoot = Dummy pos:[0,0,0] isSelected:on
                -- 拷贝原始像机
				maxOps.cloneNodes freeSourceCam cloneType:#copy newNodes:&nnl
				local cloneCam = nnl[1]
				cloneCam.name = sourceCam.name +"_Clone"
				select cloneCam
				cloneCam.parent = dummyRoot     -- 先设置parent再旋转root
                -- 旋转坐标系
                rotate dummyRoot yaw.value [0,0,1]
                -- 位置偏移 这里跟骨骼可能缩放了 需要乘一下
                move dummyRoot [offsetX.value, offsetY.value, offsetZ.value * sourceCam.scale.x * (if sourceCam.parent != undefined then sourceCam.parent.scale.x else 1)] 
                -- 位置&朝向约束
                posCtrl = Position_Constraint()
                posCstr = posCtrl.constraints
				posCstr.appendTarget cloneCam 100
				rotCtrl = Orientation_Constraint()
                rotCstr = rotCtrl.constraints
				rotCstr.appendTarget cloneCam 100
				-- 创建导出像机
				local exportCam = Freecamera isSelected:on
				exportCam.name = sourceCam.name + "_UE4_Baked"
                exportCam.pos.controller = posCtrl
				exportCam.rotation.controller = rotCtrl
				paramWire.connect cloneCam.baseObject[#FOV] exportCam.baseObject[#FOV] wireExpr
				
				-- 烘培导出像机
				select exportCam
				for obj in selection do 
				(
					temp = Point()
					for t = curStart to curEnd do 
					(
						with animate on at time t 
                        (
                            temp.transform = obj.transform
							print obj.transform
                        )
					)
					obj.transform.controller = temp.transform.controller
					delete temp
				)
				
				select freeSourceCam
				delete $
				select cloneCam
				delete $
				select dummyRoot
				delete $
				select exportCam
			)
			else
			(
				messageBox "请先选择想要导出的摄像机"
			)
		)	
	)
	
	createdialog Exporter
)
