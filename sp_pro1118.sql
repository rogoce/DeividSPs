-- Procedimiento que retorna si la poliza tuvo endosos para las coberturas de L.C., A.M. o D.P.A. Proceso de pre renovacion y renovacion automática

-- Tarifas Agosto 2015

drop procedure sp_pro1118;

create procedure "informix".sp_pro1118(a_no_poliza char(10), a_cod_cobertura char(5)) returning smallint;

define _cnt	       smallint;
define _tipo       smallint;

 let _cnt = 0;
 let _tipo = 0;

 select count(*)
   into _cnt
   from endedmae a, endedcob b
  where a.no_poliza = b.no_poliza
    and a.no_endoso = b.no_endoso
	and a.cod_endomov = '006'
	and a.actualizado = 1
	and a.no_poliza = a_no_poliza
	and b.cod_cobertura = a_cod_cobertura
	and b.cod_cobertura in (
	select cod_cobertura 
	  from prdcober
	 where cod_ramo in ('002','020','023')
	   and (nombre like '%ASIST%MEDI%'
	    or nombre like '%DA%PROP%AJEN%'
		or nombre like '%LESIO%CORP%'));

 {select count(*)
   into _cnt
   from endedmae a, endedcob b
  where a.no_poliza = b.no_poliza
    and a.no_endoso = b.no_endoso
	and b.cod_cobetura = c.cod_cobertura
	and a.cod_endomov = '006'
	and a.actualizado = 1
	and a.no_poliza = a_no_poliza
	and b.cod_cobertura in (
	select cod_cobertura 
	  from prdcober
	 where cod_ramo in ('002','020','023')
	   and (nombre like '%ASIST%MEDI%'
	    or nombre like '%DA%PROP%AJEN%'
		or nombre like '%LESIO%CORP%'));
}
 if _cnt is null then
	let _cnt = 0;
 end if 

 if _cnt > 0 then
	let _tipo = 1;
 end if

return _tipo;

end procedure

