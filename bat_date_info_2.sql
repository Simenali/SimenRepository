#mysql创建节假日存储过程
DROP PROCEDURE IF EXISTS `f_dim_day_info`; 
--/
CREATE PROCEDURE f_dim_day_info(IN start_year VARCHAR(20))
BEGIN
        DECLARE i INT;
        DECLARE start_date VARCHAR(20);
        DECLARE date_count INT;
        declare v_sqlcounts varchar(400);
        SET i=0;
        SET start_date=concat(start_year,"-01-01");
        #拼接查询总记录的SQL语句into @recordcount
        set v_sqlcounts=concat("select datediff('",start_year,"-12-31','",start_year,"-01-01') into @recordcount");
        set @sqlcounts =v_sqlcounts;
        prepare stmt from @sqlcounts;
        execute stmt;
        #获取动态SQL语句返回值
        set date_count=@recordcount;
        DELETE FROM dim_day_info;
        WHILE i<=date_count DO
                INSERT INTO dim_day_info
                    (
                        bat_date,
                        workday,
                        month_end,
                        year_day,
                        season_day,
                        week_day,
                        DAY_SHORT_DESC,
                        DAY_LONG_DESC,
                        WEEK_ID,
                        WEEK_LONG_DESC,
                        MONTH_ID,
                        MONTH_SHORT_DESC,
                        MONTH_LONG_DESC,
                        QUARTER_ID,
                        QUARTER_LONG_DESC,
                        YEAR_ID,
                        YEAR_LONG_DESC
                    )
                SELECT
                    #REPLACE(start_date,'-','')                                          bat_date,
                    start_date                                                         bat_date,
                    case when DAYOFWEEK(start_date) in ('1','7') then 'N' ELSE 'Y' END     workday,
                    case when last_day(start_date)=start_date then 'Y' ELSE 'N' END    month_end,
                    DAYOFYEAR(start_date)    year_day,
                    DATEDIFF(start_date,date(concat(year(start_date),'-',elt(quarter(start_date),1,4,7,10),'-',1)))+1    season_day,
                    case when DAYOFWEEK(start_date)-1=0 then '7' else (DAYOFWEEK(start_date)-1) END    week_day,
                    DATE_FORMAT(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),'%Y-%m-%d')  DAY_SHORT_DESC,
                    DATE_FORMAT(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),'%Y年%m月%d日') DAY_LONG_DESC,
                    DATE_FORMAT(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),'%Y%u')      WEEK_ID,
                    DATE_FORMAT(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),'%Y年第%u周')   WEEK_LONG_DESC,
                    DATE_FORMAT(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),'%Y%m')      MONTH_ID,
                    DATE_FORMAT(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),'%Y-%m')     MONTH_SHORT_DESC,
                    DATE_FORMAT(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),'%Y年第%m月')   MONTH_LONG_DESC,
                    CONCAT(DATE_FORMAT(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),'%Y'),quarter(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'))) QUARTER_ID,
                    CONCAT(DATE_FORMAT(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),'%Y'),'年第',quarter(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s')),'季度')                       QUARTER_LONG_DESC,
                    DATE_FORMAT(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),'%Y')  YEAR_ID,
                    DATE_FORMAT(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),'%Y年') YEAR_LONG_DESC
                FROM dual;
                SET i=i+1;
                SET start_date = DATE_FORMAT(date_add(STR_TO_DATE(start_date,'%Y-%m-%d %H:%i:%s'),interval 1 DAY),'%Y-%m-%d');
        END WHILE;
          SET @sqlState="update dim_day_info b,holiday_info a set b.workday=a.workday where a.bat_date=b.bat_date";
          prepare stmt from @sqlState;
          execute stmt;
END;
/
call f_dim_day_info('2019')