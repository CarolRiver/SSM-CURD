<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  Created by IntelliJ IDEA.
  User: hp
  Date: 2021/12/9
  Time: 15:13
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>员工列表</title>
    <%
        pageContext.setAttribute("path", request.getContextPath());
    %>
    <link rel="stylesheet" href="${path}/static/bootstrap-3.3.7-dist/css/bootstrap.min.css">
    <script type="text/javascript" src="${path}/static/js/jquery-1.12.4.min.js"></script>
    <script src="${path}/static/bootstrap-3.3.7-dist/js/bootstrap.js"></script>
    <script type="text/javascript">
        var totalRecord,currentPage;
        $(function (){
            $.ajax({
                    url:"${path}/list",
                    data:"pn=${param.pn}",
                    type:"GET",
                    success:function (result){
                        totalRecord = result.extend.pageinfo.pageNum;
                        currentPage = result.extend.pageinfo.pages;
                    }
            })
            $("#emp_add_model").click(function (){
                reset_form("#EmpAddModel form");
                getDepts1();
                $("#EmpAddModel").modal({
                    backdrop:"static"
                })
            })
            $("#emp_save_btn").click(function (){
                //1、模态框中填写的表单数据提交给服务器进行保存
                //1、先对要提交给服务器的数据进行校验
                if(!validate_add_form()){
                    return false;
                };
                //1、判断之前的ajax用户名校验是否成功。如果成功。
                if($(this).attr("ajax-va")=="error"){
                    return false;
                }
                //2、发送ajax请求保存员工
                $.ajax({
                    url:"${path}/emps",
                    data: $("#EmpAddModel form").serialize(),
                    type:"POST",
                    success:function (result) {
                        if (result.code == 100) {
                            //员工保存成功；
                            //1、关闭模态框
                            $("#EmpAddModel").modal('hide');
                            //2、来到最后一页，显示刚才保存的数据
                            //发送ajax请求显示最后一页数据即可
                            // to_page(totalRecord);
                            window.location.href="${path}/emps?pn="+currentPage
                        }else{
                            //显示失败信息
                            //console.log(result);
                            //有哪个字段的错误信息就显示哪个字段的；
                            if(undefined != result.extend.errorFields.email){
                                //显示邮箱错误信息
                                show_validate_msg("#email_add_input", "error", result.extend.errorFields.email);
                            }
                            if(undefined != result.extend.errorFields.empName){
                                //显示员工名字的错误信息
                                show_validate_msg("#empName_add_input", "error", result.extend.errorFields.empName);
                            }
                        }
                    }
                })
            })
            // $(document).on("click",".update_emp",function(){
            //     alert("66")
            // })
            $(".update_emp").click(function (){
                getDepts2();
                getEmp($(this).attr("edit-id"));
                $("#emp_update_btn").attr("edit-id",$(this).attr("edit-id"));
                $("#empUpdateModal").modal({
                    backdrop:"static"
                })
            })
            $("#empName_add_input").change(function(){
                //发送ajax请求校验用户名是否可用
                var empName = this.value;
                $.ajax({
                    url:"${path}/checkuser",
                    data:"empname="+empName,
                    type:"POST",
                    success:function(result){
                        if(result.code==100){
                            show_validate_msg("#empName_add_input","success","用户名可用");
                            $("#emp_save_btn").attr("ajax-va","success");
                        }else{
                            show_validate_msg("#empName_add_input","error","用户名不可用");
                            $("#emp_save_btn").attr("ajax-va","error");
                        }
                    }
                });
            });
            $("#emp_update_btn").click(function(){
                //验证邮箱是否合法
                //1、校验邮箱信息
                var email = $("#email_update_input").val();
                var regEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;
                if(!regEmail.test(email)){
                    show_validate_msg("#email_update_input", "error", "邮箱格式不正确");
                    return false;
                }else{
                    show_validate_msg("#email_update_input", "success", "");
                }
                //2、发送ajax请求保存更新的员工数据
                $.ajax({
                    url:"${path}/emp/"+$(this).attr("edit-id"),
                    type:"POST",
                    data:$("#empUpdateModal form").serialize()+"&_method=PUT",
                    success:function(result){
                        //1、关闭对话框
                        $("#empUpdateModal").modal("hide");
                        //2、回到本页面
                        window.location.href="${path}/emps?pn="+${param.pn}
                    }
                });
            });
            $(".delete_emp").click(function (){
                var empName = $(this).parents("tr").find("th:eq(2)").text();
                var empId = $(this).attr("delete-id");
                //alert($(this).parents("tr").find("td:eq(1)").text());
                if(confirm("确认删除【"+empName+"】吗？")){
                    //确认，发送ajax请求删除即可
                    $.ajax({
                        url:"${path}/emp/"+empId,
                        type:"DELETE",
                        success:function(result){
                            alert(result.msg);
                            //回到本页
                            window.location.href="${path}/emps?pn="+${param.pn}
                        }
                    });
                }
            })
            $("#check_all").click(function(){
                //attr获取checked是undefined;
                //我们这些dom原生的属性；attr获取自定义属性的值；
                //prop修改和读取dom原生属性的值
                $(".check_item").prop("checked",$(this).prop("checked"));
            });
            //点击全部删除，就批量删除
            $("#emp_delete_all_btn").click(function(){
                //
                var empNames = "";
                var del_idstr = "";
                $.each($(".check_item:checked"),function(){
                    //this
                    empNames += $(this).parents("tr").find("th:eq(2)").text()+",";
                    //组装员工id字符串
                    del_idstr += $(this).parents("tr").find("th:eq(1)").text()+"-";
                });
                //去除empNames多余的,
                empNames = empNames.substring(0, empNames.length-1);
                //去除删除的id多余的-
                del_idstr = del_idstr.substring(0, del_idstr.length-1);
                if(confirm("确认删除【"+empNames+"】吗？")){
                    //发送ajax请求删除
                    $.ajax({
                        url:"${path}/emp/"+del_idstr,
                        type:"DELETE",
                        success:function(result){
                            //回到当前页面
                            window.location.href="${path}/emps?pn="+${param.pn}
                        }
                    });
                }
            });

        })
        $(document).on("click",".check_item",function(){
            //判断当前选择中的元素是否5个
            var flag = $(".check_item:checked").length==$(".check_item").length;
            $("#check_all").prop("checked",flag);
        });
        function getDepts1(){
            $.ajax({
                url:"${path}/depts",
                type:"GET",
                success:function (result){
                    $.each(result.extend.Dept,function (){
                        var optionEle = $("<option></option>").append(this.deptName).attr("value",this.deptId);
                        optionEle.appendTo("#Dept_check");
                    })
                }
            })
        }
        function getDepts2(){
            $.ajax({
                url:"${path}/depts",
                type:"GET",
                success:function (result){
                    $.each(result.extend.Dept,function (){
                        var optionEle = $("<option></option>").append(this.deptName).attr("value",this.deptId);
                        optionEle.appendTo("#update_check");
                    })
                }
            })
        }
        function getEmp(id){
            $.ajax({
                url:"${path}/emp/"+id,
                type:"GET",
                success:function (result){
                    var empData = result.extend.emp;
                    $("#empName_update_static").text(empData.empName);
                    $("#email_update_input").val(empData.email);
                    $("#empUpdateModal input[name=gender]").val([empData.gender]);
                    $("#empUpdateModal select").val([empData.dId]);
                }
            })
        }
        function validate_add_form(){
            //1、拿到要校验的数据，使用正则表达式
            var empName = $("#empName_add_input").val();
            var regName = /(^[a-zA-Z0-9_-]{6,16}$)|(^[\u2E80-\u9FFF]{2,5})/;
            if(!regName.test(empName)){
                //alert("用户名可以是2-5位中文或者6-16位英文和数字的组合");
                show_validate_msg("#empName_add_input", "error", "用户名可以是2-5位中文或者6-16位英文和数字的组合");
                return false;
            }else{
                show_validate_msg("#empName_add_input", "success", "");
            };

            //2、校验邮箱信息
            var email = $("#email_add_input").val();
            var regEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;
            if(!regEmail.test(email)){
                //alert("邮箱格式不正确");
                //应该清空这个元素之前的样式
                show_validate_msg("#email_add_input", "error", "邮箱格式不正确");
                /* $("#email_add_input").parent().addClass("has-error");
                $("#email_add_input").next("span").text("邮箱格式不正确"); */
                return false;
            }else{
                show_validate_msg("#email_add_input", "success", "");
            }
            return true;
        }
        //显示校验结果的提示信息
        function show_validate_msg(ele,status,msg){
            //清除当前元素的校验状态
            $(ele).parent().removeClass("has-success has-error");
            $(ele).next("span").text("");
            if("success"==status){
                $(ele).parent().addClass("has-success");
                $(ele).next("span").text(msg);
            }else if("error" == status){
                $(ele).parent().addClass("has-error");
                $(ele).next("span").text(msg);m
            }
        }
        function reset_form(ele){
            $(ele)[0].reset();
            //清空表单样式
            $(ele).find("*").removeClass("has-error has-success");
            $(ele).find(".help-block").text("");
        }

    </script>
    <div class="modal fade" id="EmpAddModel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="myModalLabel">员工添加</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal">
                        <div class="form-group">
                            <label class="col-sm-2 control-label">empName</label>
                            <div class="col-sm-10">
                                <input type="text" name="empName" class="form-control" id="empName_add_input" placeholder="empName">
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">email</label>
                            <div class="col-sm-10">
                                <input type="text" name="email" class="form-control" id="email_add_input" placeholder="email@atguigu.com">
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">gender</label>
                            <div class="col-sm-10">
                                <label class="radio-inline">
                                    <input type="radio" name="gender" id="gender1_add_input" value="M" checked="checked"> 男
                                </label>
                                <label class="radio-inline">
                                    <input type="radio" name="gender" id="gender2_add_input" value="F"> 女
                                </label>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">deptName</label>
                            <div class="col-sm-4">
                                <!-- 部门提交部门id即可 -->
                                <select class="form-control" name="dId" id="Dept_check">
                                </select>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="emp_save_btn">保存</button>
                </div>
            </div>
        </div>
    </div>
    <!-- 员工修改的模态框 -->
    <div class="modal fade" id="empUpdateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title">员工修改</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal">
                        <div class="form-group">
                            <label class="col-sm-2 control-label">empName</label>
                            <div class="col-sm-10">
                                <p class="form-control-static" id="empName_update_static"></p>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">email</label>
                            <div class="col-sm-10">
                                <input type="text" name="email" class="form-control" id="email_update_input" placeholder="email@atguigu.com">
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">gender</label>
                            <div class="col-sm-10">
                                <label class="radio-inline">
                                    <input type="radio" name="gender" id="gender1_update_input" value="1" checked="checked"> 男
                                </label>
                                <label class="radio-inline">
                                    <input type="radio" name="gender" id="gender2_update_input" value="0"> 女
                                </label>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">deptName</label>
                            <div class="col-sm-4">
                                <!-- 部门提交部门id即可 -->
                                <select class="form-control" name="dId" id="update_check">
                                </select>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="emp_update_btn">更新</button>
                </div>
            </div>
        </div>
    </div>
</head>
<body>
<div class="container">
    <%--标题--%>
    <div class="row">
        <div class="col-md-12">
            <h1>劲松SSM-CRUD</h1>
        </div>
    </div>
    <%--按钮--%>
    <div class="row">
        <div class="col-md-4 col-md-offset-8">
            <button class="btn btn-primary" id="emp_add_model">新增</button>
            <button class="btn btn-danger"id="emp_delete_all_btn">删除</button>
        </div>
    </div>
    <%--成员信息--%>
    <div class="row">
        <div class="col-md-12">
            <table class="table table-hover">
                <tr>
                    <th>
                        <input type="checkbox" id="check_all"/>
                    </th>
                    <th>#</th>
                    <th>empName</th>
                    <th>gender</th>
                    <th>email</th>
                    <th>deptname</th>
                    <th>操作</th>
                </tr>
                <c:forEach items="${pageinfo.list}" var="list">
                    <tr>
                        <th><input type='checkbox' class='check_item'/></th>
                        <th>${list.empId}</th>
                        <th>${list.empName}</th>
                        <th>${list.gender=="1"?"男":"女"}</th>
                        <th>${list.email}</th>
                        <th>${list.department.deptName}</th>
                        <th>
                            <button class="btn btn-primary btn-sm update_emp" edit-id="${list.empId}">
                                <span class="glyphicon glyphicon-pencil" aria-hidden="true"></span>
                                编辑
                            </button>
                            <button class="btn btn-danger btn-sm delete_emp" delete-id="${list.empId}">
                                <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>
                                删除
                            </button>
                        </th>
                    </tr>
                </c:forEach>
            </table>
        </div>
    </div>
    <%--分页信息--%>
    <div class="row">
        <%--分页文字信息--%>
        <div class="col-md-6">
            当前${pageinfo.pageNum}页,
            总${pageinfo.pages }页,
            总${pageinfo.total }条记录
        </div>
        <%--分页条--%>
        <div class="col-md-6">
            <nav aria-label="Page navigation">
                <ul class="pagination">
                    <li><a href="${path}/emps?pn=1">首页</a></li>
                    <c:if test="${pageinfo.hasPreviousPage}">
                        <li>
                            <a href="${path}/emps?pn=${pageinfo.pageNum-1}" aria-label="Previous">
                                <span aria-hidden="true">&laquo;</span>
                            </a>
                        </li>
                    </c:if>
                    <c:forEach items="${pageinfo.navigatepageNums}" var="num">
                        <c:if test="${num==pageinfo.pageNum}">
                            <li class="active"><a href="#">${num}</a></li>
                        </c:if>
                        <c:if test="${num!=pageinfo.pageNum}">
                            <li><a href="${path}/emps?pn=${num}">${num}</a></li>
                        </c:if>
                    </c:forEach>
                    <c:if test="${pageinfo.hasNextPage}">
                        <li>
                            <a href="${path}/emps?pn=${pageinfo.pageNum+1}" aria-label="Next">
                                <span aria-hidden="true">&raquo;</span>
                            </a>
                        </li>
                    </c:if>
                    <li><a href="${path}/emps?pn=${pageinfo.pages}">末页</a></li>
                </ul>
            </nav>
        </div>
    </div>
</div>
</body>
</html>
