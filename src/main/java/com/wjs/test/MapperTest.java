package com.wjs.test;

import com.wjs.bean.Department;
import com.wjs.bean.Employee;
import com.wjs.dao.DepartmentMapper;
import com.wjs.dao.EmployeeMapper;
import org.apache.ibatis.session.SqlSession;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.UUID;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {"classpath:ApplicationContext.xml"})
public class MapperTest {
    @Autowired
    private DepartmentMapper departmentMapper;
    @Autowired
    private EmployeeMapper employeeMapper;
    @Autowired
    private SqlSession sqlSession;
    @Test
    public void test1(){
//        Department department=new Department(null,"测试部");
//        departmentMapper.insertSelective(department);
//        employeeMapper.insertSelective(new Employee(null,"杨威","0","1505030892@qq.com",2));
//        employeeMapper.insertSelective(new Employee(null,"张恒","0","1505030893@qq.com",1));
        EmployeeMapper mapper = sqlSession.getMapper(EmployeeMapper.class);
        for(int i=0;i<1000;i++){
            mapper.insertSelective(new Employee(null, UUID.randomUUID().toString().substring(0,5),"1",i+"wjs.com",1));
        }
    }
}
