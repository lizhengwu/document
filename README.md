# Oracle-DMP-
创建用户,表空间及导入dmp文件的基本语句



--创建逻辑目录
create directory mydump as'/data/DMPDIR';
--创建或修改逻辑目录
create or replace directory mydump as'/home/oracle/Documents/DMPDIR';

select * from dba_directories;

select * from dba_tablespaces;

--创建表空间表空间单个文件最大最好不要超过32G
--创建数据库但时候会设置块的初始值表空间数据文件容量与DB_BLOCK_SIZE的设置有关同时还要注意操作系统文件块大小
--4k最大表空间为：16384M8K最大表空间为：32768M16k最大表空间为：65536M32K最大表空间为：131072M64k最大表空间为：262144M
select value from v$parameter where name='db_block_size';
--查询表空间信息
select * from dba_tablespaces;
--查询已有表空间及对应数据文件
select file_name, tablespace_name, status from dba_data_files;

--创建表空间
create tablespace CPSDATA
datafile '/home/oracle/Documents/tablespaces/cpsdata1.dbf'
size 200m
autoextend on
next 100m maxsize 10240m
extent management local;
--logging是对象的属性，创建数据库对象时，oracle将日志信息记录到练级重做日志文件中。代表空间类型为永久型
--datafile表空间存放地址
--autoextendon表空间大小不够用时自动扩展
--next50m自动扩展增量为50MBmaxsize表空间最大
--extentmanagementlocal代表管理方式为本地

--注意！在实际应用中大型项目建议表数据和表索引分两个表空间，这时就需要给用户在两个表空间分配可使用空间

select file_name, tablespace_name, status from dba_data_files;

--修改表空间数据文件大小为不限制的语句为：
alter database datafile'/oradata/orcl/test1.dbf'autoextend on maxsize unlimited;

--创建表空间数据文件大小为不限制的语句为：
create tablespace test2  datafile '/oradata/orcl/test2.dbf'size 10M autoextend on maxsize unlimited;

--删除空的表空间，但是不包含物理文件
drop tablespace tablespace_name;
--删除非空表空间，但是不包含物理文件
drop tablespace tablespace_name including contents;
--删除空表空间，包含物理文件
drop tablespace tablespace_name including datafiles;
--删除非空表空间，包含物理文件
drop tablespace tablespace_name including contents and datafiles;
--如果其他表空间中的表有外键等约束关联到了本表空间中的表的字段，就要加上CASCADECONSTRAINTS
drop tablespace tablespace_name including contents and datafiles CASCADE CONSTRAINTS;


select * from dba_users;
--创建用户
create user hex_bsb_cps  identified by hex_bsb_cps
default tablespace CPSDATA;
grant   connect, resource to hex_bsb_cps;
grant create session to hex_bsb_cps;
grant read, write on directory MYDUMP to hex_bsb_cps;
grant create view to hex_bsb_cps;

create user hex_bsb_pms identified by hex_bsb_pms
default tablespace PMSDATA;
grant connect, resource to hex_bsb_pms;
grant create session to hex_bsb_pms;
grant read, write on directory MYDUMP to hex_bsb_pms;
grant create view to hex_bsb_pms;
grant create materialized view to hex_bsb_pms;

--impdp userid='hex_bsb_pms/hex_bsb_pms' directory=MYDUMP  dumpfile=BSPMS20180523.DMP remap_tablespace=PMSDATA:PMSDATA remap_schema=hex_bsb_pms:HEX_BSB_PMS logfile=BSPMS20180523.log
--impdp userid='hex_bsb_cps/hex_bsb_cps' directory=MYDUMP  dumpfile=BSCPS20180523.DMP remap_tablespace=CPSDATA:CPSDATA remap_schema=hex_bsb_cps:HEX_BSB_CPS logfile=BSCPS20180523.log
