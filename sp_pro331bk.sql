--- Renovacion Automatica. Proceso de excepciones
--- Creado 02/03/2009 por Armando Moreno

--drop procedure sp_pro331bk;

create procedure "informix".sp_pro331bk(a_no_poliza char(10))
returning char(8);

define _gerarquia     smallint;
define _centro_costo  char(3);
define _cod_sucursal  char(3);
define _renglon smallint;
define _usuario       char(8);
define _tipo_ramo     char(1);
define _cnt,_cnt2     integer;
define _cod_ramo      char(3);
define _usu_cob		  char(8);
define _usu_cob_f	  char(8);

let _usuario = null;

LET _cnt2 = 0;

select cod_sucursal
  into _cod_sucursal
  from emipomae
 where no_poliza = a_no_poliza;

select centro_costo
  into _centro_costo
  from insagen
 where codigo_agencia  = _cod_sucursal
   and codigo_compania = '001';

select count(*)
  into _cnt
  from emideren
 where no_poliza = a_no_poliza
   and activo    = 0;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

if _cnt = 0 then	--todas las excepciones estan chequeadas

	select count(*)
	  into _cnt2
	  from emideren
	 where no_poliza = a_no_poliza
	   and renglon   in(8,9);

	if _cod_ramo in('002','020') then

		let _tipo_ramo = '1';  --AUTO

		if _cnt2 = 1 then
			let _tipo_ramo = '5';  --SISTEMA LA DEBE VER AVERBOIS
		end if

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

end if

foreach

	select renglon
	  into _renglon
	  from emideren
	 where no_poliza = a_no_poliza
	   and activo    = 0
	   and renglon   <> 11	--cobros

	foreach
		select usuario
		  into _usuario
		  from emiredis
		 where cod_sucursal = _centro_costo
		   and renglon      = _renglon


		return _usuario;

	end foreach

end foreach

if _usuario is null then

		select usuario_cobros,
			   usuario_cobro_f
		  into _usu_cob,
			   _usu_cob_f
		  from emirepar;

		if _cod_ramo = "008" then
			let _usu_cob = _usu_cob_f;
		end if

		return _usu_cob;

end if

end procedure;
