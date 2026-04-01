-- Procedimiento que retorna la informacion de las polizas de vida individual
-- 
-- Creado    : 18/06/2008 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro311;

create procedure sp_pro311(a_ano smallint)
returning smallint,
          char(20),
		  char(10),
		  char(100),
		  char(5),
		  char(50),
		  smallint,
		  date,
		  date,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  date,
		  smallint,
		  char(1),
		  char(10),
		  date,
		  char(10),
		  char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _ano_sus			smallint;
define _cod_cliente		char(10);
define _nombre_cliente	char(100);
define _cod_producto	char(5);
define _nombre_producto	char(50);
define _mes_inicio		smallint;
define _vigencia_inic	date;
define _vigencia_final	date;
define _fecha_emision	date;
define _fecha_naci		date;
define _edad			smallint;
define _sexo			char(1);

define _prima			dec(16,2);
define _prima_cedida	dec(16,2);
define _prima_facul		dec(16,2);
define _suma			dec(16,2);
define _suma_cedida		dec(16,2);
define _suma_facul		dec(16,2);

define _monto_prima		dec(16,2);
define _monto_suma		dec(16,2);

define _cod_contrato	char(5);
define _no_unidad		char(5);
define _tipo_contrato	smallint;

define _nueva_renov		char(1);
define _estatus_poliza	smallint;
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_subramo	char(50);

define _nombre_nueva	char(10);
define _nombre_estatus	char(10);

define v_filtros		char(255);

set isolation to dirty read;

--CALL sp_pro03("001", "001", a_fecha, "019;") RETURNING v_filtros;

create temp table tmp_perfil(
no_documento	char(20),
no_poliza		char(10),
no_endoso		char(5),
nueva_renov		char(1)
) with no log;

foreach
 select	no_poliza,
        no_endoso
   into	_no_poliza,
        _no_endoso
   from endedmae
  where actualizado = 1
    and cod_endomov = "011"
	and year(vigencia_inic) = a_ano

	select cod_ramo,
	       nueva_renov,
		   no_documento
	  into _cod_ramo,
	       _nueva_renov,
		   _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> "019" then
		continue foreach;
	end if

	insert into tmp_perfil
	values (_no_documento, _no_poliza, _no_endoso, _nueva_renov);

end foreach

foreach
 select	no_poliza,
        no_endoso
   into	_no_poliza,
        _no_endoso
   from endedmae
  where actualizado = 1
    and cod_endomov = "002"
	and year(vigencia_inic) = a_ano

	select cod_ramo,
	       nueva_renov,
		   no_documento
	  into _cod_ramo,
	       _nueva_renov,
		   _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> "019" then
		continue foreach;
	end if

	insert into tmp_perfil
	values (_no_documento, _no_poliza, _no_endoso, "C");

end foreach

foreach																	  
 select no_documento,
 		no_poliza,
		no_endoso,
		nueva_renov
   into _no_documento,
        _no_poliza,
		_no_endoso,
		_nueva_renov
   from tmp_perfil 													  
  order by no_documento

	select year(vigencia_inic),
		   month(vigencia_inic),
		   vigencia_inic,
		   vigencia_final,
		   fecha_suscripcion,
		   estatus_poliza,
		   cod_ramo,
		   cod_subramo
	  into _ano_sus,
		   _mes_inicio,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_emision,
		   _estatus_poliza,
		   _cod_ramo,
		   _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;
	
	if _nueva_renov = "N" then
		let _nombre_nueva = "NUEVA";
	elif _nueva_renov = "R" then
		let _nombre_nueva = "RENOVADA";
	elif _nueva_renov = "C" then
		let _nombre_nueva = "CANCELADA";
	end if

	if _estatus_poliza = 1 then
		let _nombre_estatus = "VIGENTE";
	elif _estatus_poliza = 2 then
		let _nombre_estatus = "CANCELADA";
	elif _estatus_poliza = 3 then
		let _nombre_estatus = "VENCIDA";
	elif _estatus_poliza = 4 then
		let _nombre_estatus = "ANULADA";
	end if

	foreach
	 select cod_producto,
	        no_unidad,
			cod_cliente
	   into _cod_producto,
	        _no_unidad,
	        _cod_cliente 
	   from endeduni
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		select nombre,
		       fecha_aniversario,
			   sexo
		  into _nombre_cliente,
		       _fecha_naci,
			   _sexo
		  from cliclien
		 where cod_cliente = _cod_cliente;

		let _edad = sp_sis78(_fecha_naci, today);

		select nombre
		  into _nombre_producto
		  from prdprod
		 where cod_producto = _cod_producto;

		let _prima        = 0;
		let _prima_cedida = 0;
		let _prima_facul  = 0;
		let _suma         = 0;
		let _suma_cedida  = 0;
		let _suma_facul   = 0;

		foreach
		 select c.cod_contrato,
		        c.prima,
				c.suma_asegurada
		   into _cod_contrato,
		        _monto_prima,
				_monto_suma
		   from emifacon c, endedmae e
		  where c.no_poliza   = e.no_poliza
		    and c.no_endoso   = e.no_endoso
			and e.actualizado = 1
			and e.no_poliza   = _no_poliza
			and e.no_endoso   = _no_endoso
			and c.no_unidad   = _no_unidad

			let _prima = _prima + _monto_prima;
			let _suma  = _suma  + _monto_suma;

			select tipo_contrato
			  into _tipo_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;

			if _tipo_contrato = 1 then
				continue foreach;
			end if
						
			if _tipo_contrato = 3 then
				let _prima_facul = _prima_facul + _monto_prima;
				let _suma_facul  = _suma_facul  + _monto_suma;
			else
				let _prima_cedida = _prima_cedida + _monto_prima;
				let _suma_cedida  = _suma_cedida  + _monto_suma;
			end if

		end foreach

		return _ano_sus,
		       _no_documento,
		       _cod_cliente,
		       _nombre_cliente,
		       _cod_producto,		
			   _nombre_producto,
			   _mes_inicio,
			   _vigencia_inic,
			   _vigencia_final,
			   _prima,
			   _prima_cedida,
			   _prima_facul,
			   _suma,
			   _suma_cedida,
			   _suma_facul,
			   _fecha_naci,
			   _edad,
			   _sexo,
			   _nombre_nueva,
			   _fecha_emision,
			   _nombre_estatus,
			   _nombre_subramo
			   with resume;

	end foreach

end foreach

drop table tmp_perfil;

end procedure
