SELECT Tabname, owner, partnum, nrows, locklevel, flags
  FROM systables
 WHERE locklevel = 'R'
   AND tabid     > 100
   AND owner     = 'informix';