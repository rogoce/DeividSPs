-- Procedimiento que la informacion de las primas cobradas por producto para armar el presupuesto
-- 
-- Creado     : 21/06/2013 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pre03;		

create procedure "informix".sp_pre03(a_periodo1 char(7), a_periodo2 char(7))
returning char(3),
		  char(50),
		  char(10),
		  char(5),
		  char(50),
		  char(50),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _periodo1		char(7);
define _periodo2		char(7);
define _periodo			char(7);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_producto	char(5);
define _nombre_producto	char(50);
define _cod_ramo		char(3);
define _nombre_ramo		char(50);
define _vigencia_inic	date;
define _vigencia_final	date;

define _cantidad		smallint;
define _mes,_cnt     	smallint;

define _no_registro		char(10);

define _octubre			dec(16,2);
define _noviembre		dec(16,2);
define _diciembre		dec(16,2);
define _enero			dec(16,2);
define _febrero			dec(16,2);
define _marzo			dec(16,2);
define _abril			dec(16,2);
define _mayo			dec(16,2);
define _junio			dec(16,2);
define _julio			dec(16,2);
define _agosto			dec(16,2);
define _septiembre		dec(16,2);

define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _prima_cedida	dec(16,2);
define _monto_prima		dec(16,2);

define _nueva_renov		char(1);
define _nueva_renov_d	char(10);
define _tipo_prima		char(1);
define _tipo_prima_d	char(10);
define _suc_origen      char(3);
define _desc_agen       char(50);
define v_filtros        varchar(255);
define _fecha           date;
define _porc_partic_coas dec(7,4);
define _producto_presup  char(5);

set isolation to dirty read;

create temp table tmp_prod (
cod_ramo		char(3),
cod_producto	char(5),
nueva_renov		char(1),
tipo_prima		char(1),
mes				smallint,
prima			dec(16,2) default 0,
suc_origen 		char(3),
primary key (cod_ramo, cod_producto, nueva_renov, tipo_prima, mes, suc_origen)
) with no log;


CALL sp_pro307c('001','001',a_periodo1,a_periodo2) RETURNING v_filtros;	 --crea tabla temp_det que trae prima cobrada

-- Crea la Estructura de los Productos


foreach

	select cod_ramo,
	       cod_sucursal,
	       cod_producto
	  into _cod_ramo,
		   _suc_origen,
		   _cod_producto
      from temp_det
	where seleccionado = 1
	group by 1,2,3
	order by 1,2,3

	  let _producto_presup = null;

	  select producto_presup
	    into _producto_presup
		from prdprod
	   where cod_producto = _cod_producto;
	   
	  if _producto_presup is null then
	  	let _producto_presup = _cod_producto;
	  end if

	  let _cod_producto = _producto_presup;

    select count(*)
	  into _cnt
	  from tmp_prod
	 where cod_ramo     = _cod_ramo 
	   and cod_producto = _cod_producto
	   and suc_origen   = _suc_origen;

	if _cnt > 0 then
		continue foreach;
	end if


	for _mes = 1 to 12

		insert into tmp_prod (cod_ramo, cod_producto, nueva_renov, tipo_prima, mes, prima,suc_origen) 
		values (_cod_ramo, _cod_producto, "N", "C", _mes, 0,_suc_origen);

		insert into tmp_prod (cod_ramo, cod_producto, nueva_renov, tipo_prima, mes, prima,suc_origen) 
		values (_cod_ramo, _cod_producto, "R", "C", _mes, 0,_suc_origen);

	end for

end foreach

-- Actualiza las Primas de los Productos
--{

foreach

	select no_poliza,
		   vigencia_inic,
		   prima_neta,
		   cod_producto
	  into _no_poliza,
		   _fecha,
		   _monto_prima,
		   _cod_producto
      from temp_det
	 where seleccionado = 1

	 let _mes = month(_fecha);

	  let _producto_presup = null;

	  select producto_presup
	    into _producto_presup
		from prdprod
	   where cod_producto = _cod_producto;
	   
	  if _producto_presup is null then
	  	let _producto_presup = _cod_producto;
	  end if

	  let _cod_producto = _producto_presup;

	select cod_ramo,
	       nueva_renov,
		   vigencia_inic,
		   sucursal_origen,
		   vigencia_final
	  into _cod_ramo,
	       _nueva_renov,
		   _vigencia_inic,
		   _suc_origen,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Las Renovaciones de Salud son Diferentes

	if _cod_ramo = "018" then

		if (_vigencia_final - _vigencia_inic) >= 365 then
			let _nueva_renov = "R";
		else
			let _nueva_renov = "N";
		end if

	end if

	 select porc_partic_coas
	   into _porc_partic_coas 
	   from emicoama
	  where no_poliza    = _no_poliza
	    and cod_coasegur = "036"; 			

	 if _porc_partic_coas is null then
	 	let _porc_partic_coas = 100;
	 end if

	 let _monto_prima = _monto_prima * _porc_partic_coas / 100;

		-- Prima Cobrada

	update tmp_prod 
	   set prima 		= prima + _monto_prima
	 where cod_ramo		= _cod_ramo
	   and cod_producto = _cod_producto
	   and nueva_renov 	= _nueva_renov
	   and tipo_prima 	= "C"
	   and mes 			= _mes
	   and suc_origen   = _suc_origen;

end foreach
------------
------------

foreach
 select cod_ramo,
		tipo_prima,
        cod_producto,
		nueva_renov,
		suc_origen
   into _cod_ramo,
		_tipo_prima,
        _cod_producto,
		_nueva_renov,
		_suc_origen
   from tmp_prod
  group by 1, 2, 3, 4, 5
  order by 1, 2 desc, 3, 4

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nombre_producto
	  from prdprod
	 where cod_producto = _cod_producto;

	if _nueva_renov = "N" then
		let _nueva_renov_d = "NUEVA";
	else
		let _nueva_renov_d = "RENOVADA";
	end if

	if _tipo_prima = "S" then
		let _tipo_prima_d = "SUSCRITA";
	else
		let _tipo_prima_d = "COBRADA";
	end if

	let _enero 		= 0.00;		
	let _febrero 	= 0.00;		
	let _marzo 		= 0.00;	
	let _abril 		= 0.00;		
	let _mayo 		= 0.00;		
	let _junio 		= 0.00;		
	let _julio 		= 0.00;		
	let _agosto 	= 0.00;		
	let _septiembre	= 0.00;
	let _octubre	= 0.00;		
	let _noviembre 	= 0.00;	
	let _diciembre 	= 0.00;	


	select descripcion
	  into _desc_agen
	  from insagen
	 where codigo_agencia  = _suc_origen
	   and codigo_compania = '001';

	foreach 
	 select mes,
	        prima
	   into _mes,
	        _monto_prima
	   from tmp_prod
	  where cod_ramo     = _cod_ramo
	    and tipo_prima   = _tipo_prima
		and cod_producto = _cod_producto
		and nueva_renov  = _nueva_renov
		and suc_origen   = _suc_origen
    
		if _mes = 1 then
			let _enero		= _monto_prima;		
		elif _mes = 2 then
			let _febrero	= _monto_prima;		
		elif _mes = 3 then
			let _marzo		= _monto_prima;		
		elif _mes = 4 then
			let _abril		= _monto_prima;		
		elif _mes = 5 then
			let _mayo		= _monto_prima;		
		elif _mes = 6 then
			let _junio		= _monto_prima;		
		elif _mes = 7 then
			let _julio		= _monto_prima;		
		elif _mes = 8 then
			let _agosto		= _monto_prima;		
		elif _mes = 9 then
			let _septiembre	= _monto_prima;		
		elif _mes = 10 then
			let _octubre	= _monto_prima;		
		elif _mes = 11 then
			let _noviembre	= _monto_prima;		
		elif _mes = 12 then
			let _diciembre	= _monto_prima;		
		end if

	end foreach

	return _cod_ramo,
	       _nombre_ramo,
		   _tipo_prima_d,
		   _cod_producto,
		   _desc_agen,
		   _nombre_producto,
		   _nueva_renov_d,
		   _enero,		
		   _febrero,		
		   _marzo,		
		   _abril,		
		   _mayo,		
		   _junio,		
		   _julio,		
		   _agosto,		
		   _septiembre,
		   _octubre,		
		   _noviembre,	
		   _diciembre	
		   with resume;

end foreach

drop table tmp_prod;
drop table temp_det;

end procedure