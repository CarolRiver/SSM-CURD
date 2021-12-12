package com.wjs.control;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.wjs.bean.Employee;
import com.wjs.bean.Msg;
import com.wjs.service.EmployeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class EmoloyeeController {
    @Autowired
    private EmployeeService service;


    @RequestMapping("/list")
    @ResponseBody
    public Msg getEmpsWithJson(@RequestParam(value = "pn",defaultValue ="1")Integer pn){
        PageHelper.startPage(pn,5);
        List<Employee> empList = service.getEmpList();
        //包装查询后的结果 连续显示几页
        PageInfo info=new PageInfo(empList,5);
        return Msg.success().add("pageinfo",info);
    }


    @RequestMapping("/emps")
    public String getEmps(@RequestParam(value = "pn",defaultValue ="1")Integer pn,Model model){
        PageHelper.startPage(pn,5);
        List<Employee> empList = service.getEmpList();
        //包装查询后的结果 连续显示几页
        PageInfo info=new PageInfo(empList,5);
        model.addAttribute("pageinfo",info);
        return "list";
    }


    @RequestMapping(value = "/emps",method = RequestMethod.POST)
    @ResponseBody
    public Msg saveEmps(@Valid Employee employee, BindingResult result){
        if(result.hasErrors()){
            Map<String, Object> map =new HashMap<>();
            List<FieldError> errors = result.getFieldErrors();
            for (FieldError fieldError : errors) {
                System.out.println("错误的字段名："+fieldError.getField());
                System.out.println("错误信息："+fieldError.getDefaultMessage());
                map.put(fieldError.getField(), fieldError.getDefaultMessage());
            }
            return Msg.fail().add("errorFields", map);
        }else{
            service.saveEmps(employee);
            return Msg.success();
        }
    }


    @RequestMapping("/checkuser")
    @ResponseBody
    public Msg checkEmpname(String empname){
        boolean checkuser = service.checkuser(empname);
        System.out.println("hh");
        if(checkuser){
            return Msg.success();
        }else{
            return Msg.fail();
        }
    }
    @RequestMapping(value = "/emp/{id}",method = RequestMethod.GET)
    @ResponseBody
    public Msg getEmp(@PathVariable("id")Integer id){
        Employee emp = service.getEmp(id);
        return Msg.success().add("emp", emp);
    }

    @RequestMapping(value = "/emp/{empId}",method = RequestMethod.PUT)
    @ResponseBody
    public Msg updateEmp(Employee employee){
        service.update(employee);
        return Msg.success();

    }

//    @RequestMapping(value = "/emp/{id}",method = RequestMethod.DELETE)
//    @ResponseBody
//    public Msg deleteEmp(@PathVariable("id") Integer id){
//        service.deleteEmp(id);
//        return Msg.success();
//    }
    @ResponseBody
    @RequestMapping(value="/emp/{ids}",method=RequestMethod.DELETE)
    public Msg deleteEmp(@PathVariable("ids")String ids){
        //批量删除
        if(ids.contains("-")){
            List<Integer> del_ids = new ArrayList<>();
            String[] str_ids = ids.split("-");
            //组装id的集合
            for (String string : str_ids) {
                del_ids.add(Integer.parseInt(string));
            }
            service.deleteBatch(del_ids);
        }else{
            Integer id = Integer.parseInt(ids);
            service.deleteEmp(id);
        }
        return Msg.success();
    }
}
