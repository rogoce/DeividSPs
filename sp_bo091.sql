
drop procedure sp_bo091;

create procedure sp_bo091()
returning char(20),
           smallint,
		   smallint,
		   date,
		   date;
		   
define v_filtros			char(255);

define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_ramo			char(3);
define _vigencia_inic		date;
define _vigencia_final	date;

define _cant_1				smallint;
define _cant_2				smallint;

define _error				integer;
define _error_desc			char(50);
	
create temp table tmp_dif_nueva(
no_documento	char(20),
cant_1			smallint	default 0,
cant_2			smallint	default 0
);

-- Nuevas 1

let v_filtros = sp_pro34("001", "001", "2015-01", "2015-07", "*", "*", "*", "*", "016;", "*", "2");

foreach
 select no_documento
   into _no_documento
   from temp_det
  where seleccionado = 1 
  group by 1

	insert into tmp_dif_nueva (no_documento, cant_1)
	values (_no_documento, 1);
  
end foreach  

-- Nuevas 2

call sp_bo077("01/01/2015", "31/07/2015") returning _error, _error_desc;

foreach
 select no_documento,
        sum(no_pol_nueva)
   into _no_documento,
		_cant_2
   from tmp_persis
  group by no_documento

	if _cant_2 = 0 then
		continue foreach;
	end if

	let _no_poliza = sp_sis21(_no_documento);
	
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> "016" then
		continue foreach;
	end if
	
	insert into tmp_dif_nueva (no_documento, cant_2)
	values (_no_documento, 1);

end foreach

foreach
 select no_documento,
         sum(cant_1),
		 sum(cant_2)
   into _no_documento,
        _cant_1,
        _cant_2
   from tmp_dif_nueva
  group by 1 
  order by 1

	if _cant_1 <> _cant_2 then
	
		let _no_poliza = sp_sis21(_no_documento);
		
		select vigencia_inic,
				vigencia_final
		  into _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza;
  
		return _no_documento,
		       _cant_1,
			   _cant_2,
			   _vigencia_inic,
	           _vigencia_final
			   with resume;
			   
	end if
	
end foreach

drop table temp_det;
drop table tmp_persis;
drop table tmp_dif_nueva;

end procedure 





