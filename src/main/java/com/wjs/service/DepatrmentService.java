package com.wjs.service;

import com.wjs.bean.Department;
import com.wjs.dao.DepartmentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DepatrmentService {
    @Autowired
    private DepartmentMapper departmentMapper;
    public List<Department> getDepts(){
        return  departmentMapper.selectByExample(null);
    }
}
