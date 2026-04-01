--- Renovacion Automatica. Proceso de excepciones
--- Creado 02/03/2009 por Armando Moreno

--drop procedure sp_pro331a;

create procedure "informix".sp_pro331a(a_no_poliza char(10))
returning char(8);

define _gerarquia     smallint;
define _centro_costo  char(3);
define _cod_sucursal  char(3);
define _renglon smallint;
define _usuario       char(8);
define _tipo_ramo     char(1);
define _cnt,_cnt2     integer;
define _cod_ramo      char(3);

select cod_sucursal
  into _cod_sucursal
  from emipomae
 where no_poliza = a_no_poliza;

select centro_costo
  into _centro_costo
  from insagen
 where codigo_agencia  = _cod_sucursal
   and codigo_compania = '001';

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

if _cod_ramo in('002','020') then

	let _tipo_ramo = '1';  --AUTO

elif _cod_ramo in('008') then

	let _tipo_ramo = '6';  --FIANZAS

elif _cod_ramo in('016','018','019','004') then

	let _tipo_ramo = '3';  --PERSONAS

else

	let _tipo_ramo = '2';  --PATRIMONIALES
	
end if

foreach

	select gerarquia,
		   usuario
	  into _gerarquia,
	       _usuario
	  from emiredis
	 where cod_sucursal = _centro_costo
	   and tipo_ramo    = _tipo_ramo
	 order by gerarquia desc

	return _usuario;

end foreach

end procedure;
