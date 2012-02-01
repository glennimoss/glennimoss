SELECT  'SID ' || l1.sid || ' is blocking  ' || l2.sid AS blocking
FROM v$lock l1, v$lock l2
WHERE l1.block =1
  AND l2.request > 0
  AND l1.id1=l2.id1
  AND l1.id2=l2.id2;
