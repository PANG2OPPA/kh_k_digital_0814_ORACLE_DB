-- FROM 절에 사용하는 서브쿼리 : 인라인뷰
-- FROM절에 직접 테이블을 명시하여 사용하기에는 테이블 내 데이터 규모가 너무 큰 경우 사용
-- 보안이나 특정 목적으로 정보를 제공하는 경우
-- 10 부서에 해당하는 테이블만 가지고 옴
SELECT E10.EMPNO, E10.ENAME, E10.DEPTNO, D.DNAME, D.LOC
FROM (SELECT * FROM EMP
                WHERE DEPTNO = 10) E10 JOIN (SELECT * FROM DEPT) D
ON E10.DEPTNO = D.DEPTNO;

-- 먼저 정렬하고 해당 갯수만 가져오기
-- ROWNUM : 오라클에서 제공하는 문법으로 행번호를 자동으로 매겨 줌
-- 정렬된 결과에서 상위 3개를 뽑으려면 테이블을 가져올 때 정렬된 상태로 가져와야 함
-- 일반적인 SELECT문에서는 ORDER BY절이 맨 나중에 수행되기 때문
SELECT ROWNUM, ENAME, SAL
FROM (SELECT * FROM EMP         
                ORDER BY SAL DESC)
WHERE ROWNUM <= 3;

-- SELECT절에 사용하는 서브쿼리 : 스칼라 서브쿼리라고도 부름 (반드시 하나의 결과만 나와야 함)
-- 단일행으로 와야 함
SELECT EMPNO, ENAME, JOB, SAL, (SELECT GRADE
                                                            FROM SALGRADE
                                                            WHERE E.SAL BETWEEN LOSAL AND HISAL) AS 급여등급,
                                                            DEPTNO,
                                                            (SELECT DNAME
                                                            FROM DEPT
                                                            WHERE E.DEPTNO = DEPT.DEPTNO) AS DNAME
FROM EMP E;

-- 매 행마다 부서번호가 각 행의 부서번호와 동일한 사원들의 SAL 평균을 구해서 반환
SELECT ENAME, DEPTNO, SAL,
                (SELECT TRUNC(AVG(SAL))
                        FROM EMP
                        WHERE DEPTNO = E.DEPTNO) AS 부서별평균급여
FROM EMP E

-- 부서 위치가 NEW YORK인 경우에 본사로, 그 외 부서는 분점으로 반환
SELECT EMPNO, ENAME,
                CASE WHEN DEPTNO = (SELECT DEPTNO   
                                                        FROM DEPT
                                                        WHERE LOC = 'NEW YORK')
                            THEN '본사'
                            ELSE '문점'
                        EMD AS 소속
FROM EMP
ORDER BY 소속;

-- 1. 
SELECT E.JOB, E.EMPNO, D.DEPTNO, D.DNAME
FROM EMP E JOIN DEPT D
ON E.DEPTNO = D.DEPTNO
WHERE E.JOB = (SELECT JOB
                                FROM EMP    
                                WHERE ENAME = 'ALLEN');

-- 2.
SELECT E.EMPNO, E.ENAME, D.DEPTNO, D.DNAME, D.LOC, E.SAL, S.GRADE
FROM EMP E
JOIN DEPT D ON E.DEPTNO = E.DEPTNO
JOIN SALGRADE S ON E.SAL BETWEEN S.LOSAL AND S.HISAL
WHERE E.SAL > (SELECT AVG(SAL)
                            FROM EMP)
ORDER BY E.SAL DESC , E.EMPNO;

-- 3. 
SELECT E.EMPNO, E.ENAME, D.DEPTNO, D.DNAME, D.LOC
FROM EMP E JOIN DEPT D
ON E.DEPTNO = D.DEPTNO
WHERE E.DEPTNO = 10 AND E.JOB NOT IN(SELECT DISTINCT JOB
                                                                            FROM EMP
                                                                            WHERE DEPTNO = 30);

-- 4. 
SELECT E.EMPNO, E.ENAME, E.SAL, S.GRADE
FROM EMP E JOIN SALGRADE S
ON E.SAL BETWEEN S.LOSAL AND S.HISAL
WHERE E.SAL > (SELECT MAX(SAL)
                            FROM EMP
                            WHERE JOB = 'SALESMAN')
ORDER BY E.EMPNO;

-- 다중행을 사용해서 풀기
SELECT E.EMPNO, E.ENAME, E.SAL, S.GRADE
FROM EMP E JOIN SALGRADE S
ON E.SAL BETWEEN S.LOSAL AND S.HISAL
WHERE E.SAL > ALL(SELECT SAL
                            FROM EMP
                            WHERE JOB = 'SALESMAN')
ORDER BY E.EMPNO;

-- DML (DATA MANUPULATION LANGUAGE) : 데이터를 조회(SELECT), 삭제(DELETE), 입력(INSERT), 변경(UPDATE)
-- 테이블이 아니고 데이터를 조작하는 것

-- DML을 하기 위해서 임시 테이블 생성
-- 기존의 DEPT TABLE을 복사해서 DEPT_TEMP 테이블 생성
CREATE TABLE DEPT_TEMP
AS SELECT * FROM DEPT;

SELECT * FROM DEPT_TEMP;

DROP TABLE DEPT_TEMP; -- 테이블을 삭제 할 때 사용

-- 테이블에 데이터를 추가하기
INSERT INTO DEPT_TEMP(DEPTNO, DNAME, LOC) VALUES(50, 'DATABASE', '서울');
INSERT INTO DEPT_TEMP(DEPTNO, DNAME, LOC) VALUES(50, '부산', 'DEVELOPMENT');
INSERT INTO DEPT_TEMP(DEPTNO, DNAME, LOC) VALUES(70, '인천', NULL);

-- 2번째 방법
INSERT INTO DEPT_TEMP VALUES(80, '프론트', NULL);
INSERT INTO DEPT_TEMP(DEPTNO, DNAME) VALUES(90, '백엔드');
    
-- 테이블에 날자 데이터 입력하기
CREATE TABLE EMP_TEMP
AS SELECT * FROM EMP
WHERE 1 != 1; -- 테이블을 복사해 새로운 테이블을 만들 때 데이터는 복사하지 않고 싶을 때 사용

SELECT * FROM EMP_TEMP;
-- 테이블에 날짜 데이터 입력하기
INSERT INTO EMP_TEMP(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO)
        VALUES(9003, '안유진', 'MANAGER', 9000, TO_DATE('2023/09/23', 'YYYY/MM/DD'), 2000, 1000, 10);

INSERT INTO EMP_TEMP(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO)
        VALUES(9004, '가을', 'MANAGER', 9000, SYSDATE, 2000, 1000, 10);

-- 서브쿼리를 이용한 INSERT
INSERT INTO EMP_TEMP(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO)
        SELECT E.EMPNO, E.ENAME, E.JOB, E.MGR, E.HIREDATE, E.SAL, E.COMM, E.DEPTNO
        FROM EMP E JOIN SALGRADE S
        ON E.SAL BETWEEN S.LOSAL AND S.HISAL
        WHERE S.GRADE =1;

-- UPDATE : 행의 정보를 변경할 때 사용가능
-- UPDATE '테이블이름' SET '변경할 열의 이름과 데이터' WHERE '조건식'
SELECT * FROM DEPT_TEMP;

CREATE TABLE DEPT_TEMP2
AS SELECT * FROM DEPT_TEMP;

UPDATE DEPT_TEMP
        SET DNAME = '백엔드',
                LOC = '광주'
        WHERE DEPTNO = 30;

-- 테이블에 있는 데이터 삭제하기
CREATE TABLE EMP_TEMP2
AS SELECT * FROM EMP;

SELECT * FROM EMP_TEMP2;

-- 조건절없이 사용하면 모든 데이터 지워짐
DELETE FROM EMP_TEMP2
WHERE JOB = 'SALESMAN';

CREATE TABLE DEPT_TCL
AS SELECT *
FROM DEPT;

SELECT * FROM DEPT_TCL;

INSERT INTO DEPT_TCL VALUES(50, 'DATABASE', 'SEOUL');

COMMIT;

UPDATE DEPT_TCL
SET LOC = 'SEOUL'
WHERE DEPTNO = 30;