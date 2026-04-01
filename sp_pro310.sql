-- Procedimiento que retorna la informacion de las polizas de vida individual
-- 
-- Creado    : 18/06/2008 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro310;

create procedure sp_pro310(a_fecha date)
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
		  char(1);

define _no_documento	char(20);
define _no_poliza		char(10);
define _ano_sus			smallint;
define _cod_cliente		char(10);
define _nombre_cliente	char(100);
define _cod_producto	char(5);
define _nombre_producto	char(50);
define _mes_inicio		smallint;
define _vigencia_inic	date;
define _vigencia_final	date;
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

define v_filtros		char(255);

set isolation to dirty read;

CALL sp_pro03("001", "001", a_fecha, "019;") RETURNING v_filtros;

foreach																	  
 select no_documento													  
   into _no_documento												  
   from temp_perfil 													  
  order by no_documento

	let _no_poliza = sp_sis21(_no_documento);

	select year(vigencia_inic),
		   month(vigencia_inic),
		   vigencia_inic,
		   vigencia_final
	  into _ano_sus,
		   _mes_inicio,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	foreach
	 select cod_producto,
	        no_unidad,
			cod_asegurado
	   into _cod_producto,
	        _no_unidad,
	        _cod_cliente 
	   from emipouni
	  where no_poliza = _no_poliza

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
			   _sexo
			   with resume;

	end foreach

end foreach

drop table temp_perfil;

end procedure
