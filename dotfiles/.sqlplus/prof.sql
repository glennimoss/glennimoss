SET DEFINE ON

select * from (
select p.unit_name, p.occured, p.tot_time, p.line# line, substr(s.text, 1,75) text
from (
  select u.unit_name, d.TOTAL_OCCUR occured, (d.TOTAL_TIME/1000000000) tot_time, d.line#
  from plsql_profiler_units u, plsql_profiler_data d
  where d.RUNID=u.runid and d.UNIT_NUMBER = u.unit_number and d.TOTAL_OCCUR >0
  and u.runid= &1) p, --THIS RUNID MUST MATCH THE RUNID OBTAIN FROM ABOVE
  user_source s
where p.unit_name = s.name(+) and p.line# = s.line (+)
--order by p.unit_name, p.line#
order by p.tot_time desc
)
where rownum <= 10
;
