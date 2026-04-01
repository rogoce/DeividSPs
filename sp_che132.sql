-- Procedure que crea los Cheques de Planilla.
-- 
-- Creado    : 19/03/2012 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che132;		

create procedure "informix".sp_che132(a_compania char(3), a_sucursal char(3), a_usuario char(8),a_num_planilla char(10))
returning integer,
		  integer,	
          char(100);

define _detalle			varchar(100);
define _nombre			varchar(100);
define _cedula			varchar(30);
define _num_ach			varchar(10);
define _error_desc		char(100);
define _nom_planilla	char(75);
define _nom_empleado	char(50);
define _descripcion_suc char(30);
define _doc_remesa		char(20);
define _cta_banco		char(15);
define _cuenta			char(15);
define _no_requis_err	char(10);
define _cod_empleado	char(10);
define _cod_cliente		char(10);
define _no_recibo2      char(10);
define _no_requis		char(10);
define _no_eval         char(10);
define _no_recibo		char(10);
define _periodo			char(7);
define _provincia		char(7);
define _inicial			char(7);
define _asiento			char(7);
define _tomo			char(7);
define _cod_auxiliar	char(5);
define _cod_sucursal	char(3);
define _centro_costo	char(3);
define _chequera		char(3);
define _cod_ruta		char(3);
define _cod_suc         char(3);
define _banco			char(3);
define _origen_cheque	char(1);
define _tipo_requis		char(1);
define _cta_aux			char(1);
define _null			char(1);
define _credito			dec(16,2);
define _debito			dec(16,2);
define _monto			dec(16,2);
define _renglon_che		smallint;
define _cnt_cheque		smallint;
define _autorizado		smallint;
define _existe			smallint;
define _pagado			smallint;
define _cobrado			smallint;
define _renglon			smallint;
define _error_isam		integer;
define _no_cheque		integer;
define _cantidad		integer;
define _tot_reg			integer;
define _error			integer;
define _cnt             integer;
define _fecha_cobrado	date;
define _fecha_recibo2	date;
define _fecha_recibo	date;
define _fecha			date;


begin
on exception set _error, _error_isam, _error_desc
	let _error_desc = trim(_error_desc) || trim(cast(_no_cheque as char(10)));
	return _error,_error_isam, _error_desc;									   
end exception

set isolation to dirty read;
--Banco y Chequera
let _descripcion_suc	= "";								 
let _no_requis_err		= "";								 
let _origen_cheque		= "P";								 
let _cod_sucursal		= '001';
let _chequera			= "013";
let _banco				= "001";
let _autorizado			= 1;
let _pagado				= 1;
let _cobrado			= 0;
let _fecha_cobrado		= null;
let _cod_cliente		= null;
let _cod_ruta			= null;
let _cod_suc			= null;

--set debug file to "sp_che132.trc";
--trace on;
	
--Centro de costo
call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

select nombre,
	   cta_banco,
	   fecha	
  into _nom_planilla,
	   _cta_banco,
	   _fecha
  from chqpayasien
 where num_planilla = a_num_planilla;

if _fecha is null then
	let _fecha = current;
end if

let _periodo = sp_sis39(_fecha);

select count(distinct cod_empleado)
  into _tot_reg
  from chqpaydet
 where num_planilla = a_num_planilla
   and nombre_empleado is not null;

foreach
	select distinct cod_empleado,
		   nombre_empleado,
		   no_cheque,
		   num_ach
	  into _cod_empleado,
		   _nom_empleado,
		   _no_cheque,
		   _num_ach
	  from chqpaydet
	 where num_planilla = a_num_planilla
	   and nombre_empleado is not null

	select abs(monto),
		   cedula_emp
	  into _monto,
		   _cedula	
	  from chqpaydet
	 where num_planilla = a_num_planilla
	   and cod_empleado = _cod_empleado
	   and cuenta		= _cta_banco;

	let _no_requis = sp_sis13(a_compania, 'CHE', '02', 'par_cheque');

	if _no_cheque is null or _no_cheque = 0 then
		let _no_cheque = cast(_num_ach as integer);
		let _tipo_requis   = "A";
	else
		let _no_cheque = cast(_no_cheque as integer);
		let _tipo_requis   = "C";
	end if

	call sp_sis108(_cedula,1) returning _existe,_cod_cliente;					   

	if _existe = 0 then

		call sp_sis400(_cedula) returning _provincia,_inicial,_tomo,_asiento;																	   
		let _null = null;

		call sp_sis372(_cod_cliente,   --ls_valor_nuevo char(10),				    
					   0,			   --ll_nrocotizacion int,  			   
					   'N',			   --ls_tipopersona char(1),   				    
					   'A',			   --ls_tipocliente char(1),   			   
					   _nom_empleado,  --ls_primernombre char(40),  				    
					   '',			   --ls_segundonombre char(40), 			    
					   '',			   --ls_primerapellido char(40), 			    
					   '',			   --ls_segundoapellido char(40),			 
					   _null,		   --ls_apellidocasada char(40),			 
					   _nom_empleado,  --ls_razonsocial char(100),   			 
					   _cedula,		   --ls_cedula char(30),        				 
					   _null,		   --ls_ruc char(30),           				 
					   _null,		   --ls_pasaporte char(30),     				 
					   _null,		   --ls_direccion char(50),     				 
					   _null,		   --ls_apartado char(20),      				 
					   _null,		   --ls_telefono1 char(10),     				 
					   _null,		   --ls_telefono2 char(10),     			 
					   _null,		   --ls_fax char(10),           			 
					   _null,		   --ls_email char(50),         			 
					   _null,		   --ld_fechaaniversario	date,			 
					   _null,		   --ls_sexo char(1),   			 
					   a_usuario,	   --ls_usuario char(8),			 
					   '001',		   --ls_compania	char(3),			 
					   '001',		   --ls_agencia char(3),			 
					   _provincia,	   --ls_provincia char(2),			 
					   _inicial,	   --ls_inicial char(2),			 
					   _tomo,		   --ls_tomo char(7),			 
					   '',			   --ls_folio char(7),			 
					   _asiento,	   --ls_asiento char(7),			 
					   '',			   --ls_direccion2 varchar(50) de			 
					   _null) 		   --ls_celular varchar(10)
					   returning _error;

		if _error <> 0 then
			return _error,1,'Error al crear al empleado, intente nuevamente';
		end if 		 	 
	end if

	let _detalle     = _nom_planilla;
	let _detalle     = trim(_detalle);

	insert into chqchmae(
	no_requis,
	cod_cliente,
	cod_agente,
	cod_banco,
	cod_chequera,
	cuenta,
	cod_compania,
	origen_cheque,
	no_cheque,
	fecha_impresion,
	fecha_captura,
	autorizado,
	pagado,
	a_nombre_de,
	cobrado,
	fecha_cobrado,
	anulado,
	fecha_anulado,
	anulado_por,
	monto,
	periodo,
	user_added,
	autorizado_por,
	tipo_requis,
	impreso_ok,
	centro_costo,
	cod_ruta,
	sac_asientos,
	cod_sucursal
	)
	values(
	_no_requis,		-- no_requis,
	_cod_cliente,	-- cod_cliente,
	null,			-- cod_agente,
	_banco,			-- cod_banco,
	_chequera,		-- cod_chequera,
	null,			-- cuenta,
	a_compania,		-- cod_compania,
	_origen_cheque,	-- origen_cheque,
	_no_cheque,		-- no_cheque,
	_fecha,			-- fecha_impresion
	_fecha,			-- fecha_captura,
	_autorizado,	-- autorizado,
	_pagado,		-- pagado,
	_nom_empleado,	-- a_nombre_de,
	_cobrado,		-- cobrado,
	_fecha_cobrado,	-- fecha_cobrado,
	0,				-- anulado,
	null,			-- fecha_anulado,
	null,			-- anulado_por,
	_monto,			-- monto,
	_periodo,		-- periodo,
	a_usuario,		-- user_added,
	a_usuario,		-- autorizado_por,
	_tipo_requis,	-- tipo_requis,
	1,				-- impreso_ok,
	_centro_costo,	-- centro_costo,
	_cod_ruta,		-- cod_ruta,
	0,				-- sac_asientos
	_cod_sucursal
	);
	
	let _renglon_che = 1;
	-- Descripcion del Cheque
	insert into chqchdes(
	no_requis,
	renglon,
	desc_cheque
	)
	values(
	_no_requis,							 
	_renglon_che,
	_detalle
	);

	let _renglon = 0;
	foreach
		select nombre_empleado,
			   cuenta,
		   	   monto,
			   no_cheque,
			   cedula_emp
		  into _nom_empleado,
			   _cuenta,
			   _monto,
			   _no_cheque,
			   _cedula
		  from chqpaydet
		 where num_planilla = a_num_planilla
		   and cod_empleado = _cod_empleado
		 order by renglon		   	   		  									   

		-- Cuentas del Cheque													   
		let _renglon = _renglon + 1;
		if _monto > 0 then														   
			let _debito  = _monto;												   
			let _credito = 0.00;												   
		else																	   
			let _debito  = 0.00;												   
			let _credito = _monto * - 1;										   
		end if																	   						

		select cta_auxiliar														   
		  into _cta_aux															   
		  from cglcuentas														   
		 where cta_cuenta = _cuenta;											   

		let _cod_auxiliar = null;												 	   

   		if _cta_aux = 'S' then											 	   
			call sp_sac203(_cod_cliente) returning _cod_auxiliar;		 	   
		end if															 	   

		insert into chqchcta(											 	   
		no_requis,														 	   
		renglon,														 
		cuenta,															 
		debito,															 
		credito,														 
		cod_auxiliar,													 
		tipo,															 
		centro_costo													 
		)																 
		values(															 
		_no_requis,														 
		_renglon,														 
		_cuenta,
		_debito,
		_credito,
		_cod_auxiliar,
		1,
		_centro_costo
		);

		if _cta_aux = 'S' then

			insert into chqctaux(
				   no_requis,
				   renglon,
				   cuenta,
				   cod_auxiliar,
				   debito,
				   credito,
				   tipo,
				   centro_costo
				   )
			values(
				   _no_requis,
				   _renglon,
				   _cuenta,
				   _cod_auxiliar,
				   _debito,
				   _credito,
				   1,
				   _centro_costo
				   );
		end if
	end foreach
	return 1,_tot_reg,'' with resume;
end foreach

{call sp_sac61(a_usuario,6) returning _error, _error_desc;

if _error <> 0 then
	return _error,_error_desc;
end if}

update chqpayasien
   set actualizado	= 1
 where num_planilla	= a_num_planilla;

end

return 0,0, "Actualizacion Exitosa";

end procedure
