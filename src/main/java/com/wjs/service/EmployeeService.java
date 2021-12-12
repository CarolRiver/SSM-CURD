package com.wjs.service;

import com.wjs.bean.Employee;
import com.wjs.bean.EmployeeExample;
import com.wjs.bean.Msg;
import com.wjs.dao.EmployeeMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class EmployeeService {
    @Autowired
    private EmployeeMapper mapper;
    public List<Employee> getEmpList(){
        return mapper.selectByExamplewithDept(null);
    }

    public void  saveEmps(Employee employee) {
        mapper.insertSelective(employee);
    }

    public boolean checkuser(String empName) {
        EmployeeExample example=new EmployeeExample();
        EmployeeExample.Criteria criteria = example.createCriteria();
        criteria.andEmpNameEqualTo(empName);
        long l = mapper.countByExample(example);
        return l==0;
    }

    public Employee getEmp(Integer id) {
        Employee employee = mapper.selectByPrimaryKey(id);
        return employee;
    }

    public void update(Employee employee) {
        mapper.updateByPrimaryKeySelective(employee);
    }

    public void deleteEmp(Integer id) {
        mapper.deleteByPrimaryKey(id);
    }
    public void deleteBatch(List<Integer> ids) {
        // TODO Auto-generated method stub
        EmployeeExample example = new EmployeeExample();
        EmployeeExample.Criteria criteria = example.createCriteria();
        //delete from xxx where emp_id in(1,2,3)
        criteria.andEmpIdIn(ids);
        mapper.deleteByExample(example);
    }

}
