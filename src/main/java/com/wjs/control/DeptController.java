package com.wjs.control;

import com.wjs.bean.Department;
import com.wjs.bean.Msg;
import com.wjs.dao.DepartmentMapper;
import com.wjs.service.DepatrmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
public class DeptController {
    @Autowired
    private DepatrmentService departService;
    @RequestMapping("/depts")
    @ResponseBody
    public Msg getDept(){
        List<Department> list = departService.getDepts();
        return Msg.success().add("Dept",list);
    }

}
