-- Insertando los valores de cambios de productos de las cartas de Salud en emicartasal2.
-- Creado    : 15/07/2010 - Autor: Henry Giron.
-- Modificado: 15/07/2010 - Autor: Henry Giron.
-- SIS v.2.0 -  - DEIVID, S.A.	  copia del sp_pro497.

drop procedure sp_pro4951;
create procedure sp_pro4951(
    a_no_documento	char(20),
    a_dir			char(100),
    a_tel_pag1		char(10),
    a_tel_pag2		char(10),
    a_nom_agente	varchar(50), 
    a_usuario		char(8) default null,
    a_dir1			varchar(50),
    a_dir2			varchar(50),
    a_email			varchar(50))
returning smallint,char(25);

define _nombre            	varchar(100);
define _nombre_ramo			char(100);
define _nombre_plan			char(100);
define _nombre_subramo		char(100);
define _producto_nom     	char(50);
define _cod_asegurado		char(10);
define _cod_depend       	char(10);
define _no_poliza			char(10);
define _periodo_ant   	    char(7);
define _cod_producto_new	char(5);
define _cod_producto_ant    char(5);
define _cod_producto		char(5);
define _no_unidad       	char(5);
define _cod_grupo			char(5);
define _cod_formapag		char(3);
define _cod_perpago			char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _anio_aniv			char(4);
define _mes_aniv			char(2);
define _dia_aniv			char(2);
define _prima_plan_aseg		dec(16,2);
define _prima_asegurado 	dec(16,2);
define _prima_plan_dep		dec(16,2);
define _deducible_int		dec(16,2);
define _prima_bruta         dec(16,2);
define _prima_plan 			dec(16,2);
define _deducible			dec(16,2);
define _prima_ant       	dec(16,2);
define _co_pago  			dec(16,2);
define _porc_descuento      dec(5,2);
define _porc_impuesto       dec(5,2);
define _porc_recargo        dec(5,2);
define _por_recargo			dec(5,2);
define _fecha_aniversario	date;
define _fecha_periodo   	date;
define _fecha_actual        date;
define _desde				date;
define _error               smallint; 
define _edad            	smallint;
define _deducible_din		money(16,2);
define a_nom_cliente        varchar(100);
define a_periodo            char(7);
define a_fecha_aniv, _vigencia_inic date;
define _cnt_ducruet         smallint;
define _tipo_cambio         smallint;

--if a_no_documento = '1816-00280-01' then
--  set debug file to "sp_pro4951.trc";
--  trace on;
--end if

set isolation to dirty read;

select valor_parametro
  into a_periodo
  from inspaag
 where codigo_compania = '001'
   and codigo_agencia = '001'
   and aplicacion = 'PRO'
   and version = '02'
   and codigo_parametro = 'cambio_producto';

let _fecha_actual  = sp_sis26() ;
let _fecha_periodo = mdy(a_periodo[6,7], 1, a_periodo[1,4]);

let _nombre_plan = "";
let _prima_bruta = 0;
let _tipo_cambio = 0;

--if a_fecha_aniv < _fecha_periodo then
{	let _anio_aniv =   a_periodo[1,4];
	let _mes_aniv  =   month(a_fecha_aniv);
	let _dia_aniv  =   day(a_fecha_aniv);
	let a_fecha_aniv = mdy(_mes_aniv,_dia_aniv,_anio_aniv);}
--	let a_fecha_aniv = a_fecha_aniv + 1 units year;
--end if 

begin
 
on exception set _error 

	if _error = -268 or _error = -239 then 
 		update emicartasal2
 		   set  nombre_cliente = a_nom_cliente,
 		        fecha_aniv     = a_fecha_aniv,		
				direccion      = a_dir,
				telefono1      = a_tel_pag1,
				telefono2      = a_tel_pag2,
				nombre_agente  = a_nom_agente,
				user_added     = a_usuario,
				date_added     = current,
				cod_subramo    = _cod_subramo,
				cod_producto   = _cod_producto,
				prima          = _prima_plan,
				cod_perpago    = _cod_perpago,
				cod_formapag   = _cod_formapag,
				periodo        = a_periodo,
				cod_grupo      = _cod_grupo,
				deducible      = _deducible,
				co_pago        = _co_pago,
				nombre_plan    = _nombre_plan,
				enviado_a      = 0,
				impreso        = 0,
				deducible_int  = _deducible_int,
				cod_producto_ant = _cod_producto_ant,
				prima_ant        = _prima_ant,
				periodo_ant      = _periodo_ant,
                tipo_cambio      = _tipo_cambio,		
                enviado_email    = null,
                fecha_email      = null				
 		 where  no_documento = a_no_documento; 
	else
{		set debug file to "sp_pro4951.trc";
		trace on;
		
		let a_no_documento = a_no_documento;
		let _cod_producto = _cod_producto;
}	
 		return _error, "error al actualizar";         
	end if
end exception 
 
 call sp_sis21(a_no_documento) returning _no_poliza;

If _no_poliza is not null then 
	select cod_ramo,
		   cod_subramo,
		   cod_perpago,
		   cod_formapag,
		   cod_grupo,
		   prima_bruta,
		   periodo,
		   vigencia_inic
	  into _cod_ramo,
		   _cod_subramo,
		   _cod_perpago,
		   _cod_formapag,
		   _cod_grupo,
		   _prima_bruta,
		   _periodo_ant,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	let _cnt_ducruet = 0;
	
	select count(*) 
	  into _cnt_ducruet
	  from emipoagt
	 where no_poliza = _no_poliza
	   and cod_agente in ('00815','00035','02154','02904') ;
	 
	if month(_vigencia_inic) < month(_fecha_periodo) then
		let _anio_aniv =   a_periodo[1,4];
		let _mes_aniv  =   month(_vigencia_inic);
		let _dia_aniv  =   day(_vigencia_inic);
		let a_fecha_aniv = mdy(_mes_aniv,_dia_aniv,_anio_aniv);
		let a_fecha_aniv = a_fecha_aniv + 1 units year;
	else
		let _anio_aniv =   a_periodo[1,4];
		let _mes_aniv  =   month(_vigencia_inic);
		let _dia_aniv  =   day(_vigencia_inic);
		let a_fecha_aniv = mdy(_mes_aniv,_dia_aniv,_anio_aniv);
	end if
	
	LET _anio_aniv = YEAR(a_fecha_aniv);

	IF MONTH(a_fecha_aniv) < 10 THEN
		LET _mes_aniv = '0' || MONTH(a_fecha_aniv);
	ELSE
		LET _mes_aniv = MONTH(a_fecha_aniv);
	END IF

	LET a_periodo = _anio_aniv || '-' || _mes_aniv;
	
	delete from eminocartsal where no_documento = a_no_documento and periodo = a_periodo;

	select trim(nombre) 
	  into _nombre_ramo 
	  from prdramo 
	 where cod_ramo = _cod_ramo ;

	select trim(nombre)
	  into _nombre_subramo
	  from prdsubra 
	 where cod_ramo		= _cod_ramo 
	   and cod_subramo	= _cod_subramo;

	 let _nombre_plan =  trim(_nombre_ramo) || " " || trim(_nombre_subramo);

	  foreach
		select cod_producto,
			   prima_asegurado,
			   cod_asegurado 
		  into _cod_producto,
			   _prima_asegurado,
			   _cod_asegurado
		  from emipouni
		 where no_poliza = _no_poliza
		   and activo = 1
		exit foreach;
	  end foreach

	let _cod_producto_ant = _cod_producto;
	let _prima_ant = _prima_asegurado;
    let _cod_producto_new = null;
	
	if _cnt_ducruet > 0 then
		select producto_nuevo,
			   desde
		  into _cod_producto_new,
			   _desde
		  from prdnewpro2
		 where cod_producto = _cod_producto
			and a_fecha_aniv >= desde
			and a_fecha_aniv < hasta
			and activo = 1;
			
		let _tipo_cambio = 0;
	else
		select producto_nuevo,
			   desde
		  into _cod_producto_new,
			   _desde
		  from prdnewpro
		 where cod_producto = _cod_producto
			and a_fecha_aniv >= desde
			and a_fecha_aniv < hasta
			and activo = 1;
			
		let _tipo_cambio = 0;	
	end if
	
	  -- tarifas nuevos productos
	let _prima_plan = 0;
	let _prima_plan_aseg = 0;
	let _prima_plan_dep = 0;

	if _cod_producto_new is not null then
		let _cod_producto = _cod_producto_new;
	else 
		foreach
			select cod_asegurado,
				   no_unidad 
			  into _cod_asegurado,
				   _no_unidad
			  from emipouni
			 where no_poliza = _no_poliza
			   and activo = 1

			select nombre
			  into a_nom_cliente
			  from cliclien
			 where cod_cliente = _cod_asegurado;
				
			insert into eminocartsal(
				no_documento,
				nombre_cliente,
				fecha_aniv,
				cod_subramo,
				periodo,
				cod_producto_ant,
				prima_ant)
				values(
				a_no_documento,
				a_nom_cliente,
				a_fecha_aniv,
				_cod_subramo,
				a_periodo,
				_cod_producto,
				_prima_ant
				);
		end foreach
		return 0, "Sin Cambio";
	end if

	foreach
		select cod_asegurado,
			   no_unidad 
		  into _cod_asegurado,
			   _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		   and activo = 1

		select nombre, fecha_aniversario
		  into a_nom_cliente, _fecha_aniversario
		  from cliclien
		 where cod_cliente = _cod_asegurado;

		let _edad = sp_sis78(_fecha_aniversario, a_fecha_aniv);
			 
		select prima
		  into _prima_plan
		  from prdtaeda
		 where cod_producto	= _cod_producto
		   and edad_desde	<= _edad
		   and edad_hasta	>= _edad;
		  
		let _porc_recargo = 0.00;

		foreach
			select porc_recargo
			  into _porc_recargo
			  from emiunire
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			let _prima_plan = _prima_plan + _prima_plan * _porc_recargo / 100;
		end foreach

		let _prima_plan_aseg = _prima_plan;
		let _prima_plan = 0;

		foreach
			select cod_cliente
			  into _cod_depend
			  from emidepen
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and activo = 1

			select nombre, fecha_aniversario
			  into _nombre, _fecha_aniversario
			  from cliclien
			 where cod_cliente = _cod_depend;

			let _edad = sp_sis78(_fecha_aniversario, a_fecha_aniv);
			 
			select prima
			  into _prima_plan
			  from prdtaeda
			 where cod_producto = _cod_producto
			   and edad_desde   <= _edad
			   and edad_hasta   >= _edad;
			   
		    let _porc_recargo = 0.00;
			   		
			select sum(por_recargo)
			  into _por_recargo
			  from emiderec
			 where no_poliza 	= _no_poliza
			   and no_unidad	= _no_unidad
			   and cod_cliente	= _cod_depend;

			if _por_recargo is null then 
				let _por_recargo = 0.00;
			end if

			let _prima_plan = _prima_plan * (_por_recargo / 100) + _prima_plan;
			let _prima_plan_dep = _prima_plan_dep + _prima_plan;

		end foreach

		let _prima_plan = _prima_plan_aseg + _prima_plan_dep;

	end foreach

	let _deducible     = 0;
	let _deducible_int = 0;
	let _co_pago       = 0;
	let _porc_impuesto = 0;

	  -- impuesto	
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = _no_poliza;

	if _porc_impuesto is null then
		let _porc_impuesto = 0;
	end if

	let _prima_plan = _prima_plan * (_porc_impuesto / 100) + _prima_plan;
	let _prima_ant = _prima_ant * (_porc_impuesto / 100) + _prima_ant; 

	select nombre
	  into _producto_nom
	  from prdprod
	 where cod_producto = _cod_producto;

	select deducible_fuera,deducible_local 
	  into _deducible_int,_deducible
	  from prdcobsa 
	 where cod_producto = _cod_producto 
	   and cod_cobertura in ( '00566') 
	   and cod_tipo in ('005');

	if _deducible is null then
		let _deducible = 0;
	end if

	if _deducible_int is null then
		let _deducible_int = 0;
	end if

	select co_pago 
	  into _co_pago
	  from prdcobsa 
	 where cod_producto = _cod_producto 
	   and cod_cobertura in ( '00552') 
	   and cod_tipo in ('001');

	if _co_pago is null then
		let _co_pago   = 0;
	end if

	set lock mode to wait;

--	insert into emicartasal3
--	select * from emicartasal2 where no_documento = a_no_documento;

--	delete from emicartasal2 where no_documento = a_no_documento;

	insert into emicartasal2(
			no_documento,
			nombre_cliente,
			fecha_aniv,
			direccion,
			telefono1,
			telefono2,
			celular,
			nombre_agente,
			user_added,
			date_added,
			por_edad,
			cod_subramo,
			cod_producto,
			prima,
			cod_perpago,
			cod_formapag,
			periodo,
			cod_grupo,
			deducible,
			co_pago,
			nombre_plan,
			enviado_a,
			impreso,
			deducible_int,
			cod_producto_ant,
			prima_ant,
			periodo_ant,
			tipo_cambio)
	values(
			a_no_documento,
			a_nom_cliente,
			a_fecha_aniv,  
			a_dir,           
			a_tel_pag1,    
			a_tel_pag2,    
			null,     
			a_nom_agente,
			a_usuario,
			current,
			0,
			_cod_subramo,
			_cod_producto,
			_prima_plan, 
			_cod_perpago, 
			_cod_formapag,
			a_periodo,
			_cod_grupo,
			_deducible,
			_co_pago,
			_nombre_plan,
			0,
			0,
			_deducible_int,
			_cod_producto_ant,
			_prima_ant,
			_periodo_ant,
			_tipo_cambio);

	update cliclien
	   set direccion_1	= trim(a_dir1),
		   direccion_2	= trim(a_dir2),
		   e_mail		= trim(a_email)
	 where cod_cliente	= _cod_asegurado;
end if
end
return 0, "actualizacion exitosa";
end procedure;



