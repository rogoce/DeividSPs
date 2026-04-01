drop procedure sp_par68;

create procedure sp_par68()
returning char(10),
          char(5),
		  char(25),
		  dec(16,2),
		  dec(16,2),
		  smallint;

define _no_poliza	char(10);
define _no_endoso	char(5);
define _cuenta		char(25);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _tipo_comp	smallint;


foreach
select no_poliza,
       no_endoso,
	   cuenta,
	   debito,
	   credito,
	   tipo_comp
  into _no_poliza,
       _no_endoso,
	   _cuenta,
	   _debito,
	   _credito,
	   _tipo_comp
  from endasien
 order by 1, 2

	return _no_poliza,
	       _no_endoso,
		   _cuenta,
		   _debito,
		   _credito,
		   _tipo_comp
		   with resume;

end foreach

end procedure