CREATE OR REPLACE PROCEDURE insert_city
IS 
  CURSOR employees_temp_cursor IS SELECT city FROM employees_temp;
  CURSOR locations_cursor IS SELECT city FROM locations;
  flag BOOLEAN := false;
  max_id NUMBER;
BEGIN
  FOR rec_temp IN employees_temp_cursor
  LOOP
    flag := false;

    FOR rec IN locations_cursor
    LOOP
      IF rec_temp.city = rec.city THEN
        flag := true;
        EXIT; -- Exit the loop once a match is found
      END IF;
    END LOOP;

    IF flag = FALSE THEN 
      SELECT MAX(location_id) + 1 INTO max_id FROM locations;
      INSERT INTO locations(location_id, city, country_id) VALUES (max_id, rec_temp.city, 'EG');
    END IF;
  END LOOP;
END;
/
EXECUTE insert_city();
CREATE OR REPLACE PROCEDURE insert_dept
IS 
  CURSOR employees_temp_cursor IS SELECT department_name, city FROM employees_temp;
  CURSOR locations_cursor IS SELECT department_name, location_id FROM departments;
  flag BOOLEAN := false;
  v_location_id NUMBER;
  max_id NUMBER;
  v_city varchar2(20);
BEGIN
  FOR rec_temp IN employees_temp_cursor
  LOOP
    flag := false;

    FOR rec IN locations_cursor
    LOOP
     SELECT city into v_city FROM locations WHERE location_id = rec.location_id;
      IF rec_temp.department_name = rec.department_name and rec_temp.city=v_city THEN    -- Check if the location is also the same
          flag := true;
          EXIT; -- Exit the loop once a match is found
      END IF;
    END LOOP;

    IF flag = FALSE THEN 
      SELECT MAX(department_id) + 1 INTO max_id FROM departments;
      SELECT location_id INTO v_location_id FROM locations WHERE city = rec_temp.city;
      INSERT INTO departments(department_id, department_name, location_id) VALUES (max_id, rec_temp.department_name, v_location_id);
    END IF;
  END LOOP;
END;
/
EXECUTE insert_dept();
CREATE OR REPLACE PROCEDURE insert_job
IS 
  CURSOR employees_temp_cursor IS SELECT job_title FROM employees_temp;
  CURSOR employees_cursor IS SELECT job_title FROM jobs;
  flag BOOLEAN := false;
BEGIN
  FOR rec_temp IN employees_temp_cursor
  LOOP
    flag := false;

    FOR rec IN employees_cursor
    LOOP
      IF rec_temp.job_title = rec.job_title THEN
        flag := true;
        EXIT; -- Exit the loop once a match is found
      END IF;
    END LOOP;

    IF flag = FALSE THEN 
      INSERT INTO jobs(job_id, job_title) VALUES (SUBSTR(rec_temp.job_title, 1,3), rec_temp.job_title);
    END IF;
  END LOOP;
END;
/
EXECUTE insert_job;
commit;
CREATE OR REPLACE PROCEDURE insertionpro
IS 
  CURSOR employees_temp_cursor IS 
    SELECT JOB_TITLE, FIRST_NAME, LAST_NAME, HIRE_DATE, SALARY, EMAIL, DEPARTMENT_NAME, CITY
    FROM employees_temp;

  CURSOR employees_cursor IS 
    SELECT job_id, FIRST_NAME, LAST_NAME, HIRE_DATE, SALARY, EMAIL, DEPARTMENT_ID
    FROM employees;

  flag BOOLEAN := false;
  v_job_id jobs.job_id%TYPE;
  v_department_id departments.department_id%TYPE;
  v_date employees.hire_date%TYPE;
  v_loc_id locations.location_id%TYPE;
  v_emp_id employees.employee_id%TYPE;
BEGIN
  FOR rec_temp IN employees_temp_cursor
  LOOP
    flag := false;
    SELECT job_id INTO v_job_id FROM jobs WHERE job_title = rec_temp.JOB_TITLE;
    SELECT location_id  into v_loc_id from locations where city =rec_temp.city;
    SELECT department_id INTO v_department_id FROM departments WHERE department_name = rec_temp.DEPARTMENT_NAME and location_id = v_loc_id;

    -- Convert the HIRE_DATE format from MM/DD/YYYY to DD/MM/YYYY
    v_date := TO_DATE(rec_temp.HIRE_DATE, 'DD/MM/YYYY');

    -- Validate email format using INSTR for '@'
    IF INSTR(rec_temp.EMAIL, '@') >0 THEN
      FOR rec IN employees_cursor
      LOOP
        IF v_job_id = rec.job_id
           AND rec_temp.FIRST_NAME = rec.FIRST_NAME
           AND rec_temp.LAST_NAME = rec.LAST_NAME
           AND v_department_id = rec.department_id THEN
          flag := true;
          EXIT; -- Exit the loop once a match is found
        END IF;
      END LOOP;

      IF flag = FALSE THEN 
        SELECT MAX(employee_id) + 1 INTO v_emp_id FROM employees;
        INSERT INTO employees (employee_id, job_id, first_name, last_name, hire_date, salary, email, department_id) 
        VALUES (v_emp_id, v_job_id, rec_temp.FIRST_NAME, rec_temp.LAST_NAME, v_date, rec_temp.SALARY, rec_temp.EMAIL, v_department_id);
      END IF;
    ELSE
      -- Handle invalid email format (You may raise an exception, log, or handle it as appropriate)
      DBMS_OUTPUT.PUT_LINE('Invalid email format: ' || rec_temp.EMAIL);
    END IF;
  END LOOP;
END;
/


select * from employees;
begin
insertionpro();
end;
select *from employees;

