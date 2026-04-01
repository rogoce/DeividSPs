-- Procedimiento que Crea los Registros para los Auditores - Deloitte
-- 
-- Creado     : 29/10/2008 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud13;

create procedure "informix".sp_aud13(
a_periodo1	char(7),
a_periodo2	char(7)
) returning integer,
            char(50);

define _cod_sucursal	char(3);
define _nombre_suc		char(50);
define _fecha			date;
define _fechatrx		date;
define _notrx			integer;
define _cuenta			char(25);
define _nombre_cuenta	char(50);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _tipo_comp		smallint;
define _con_descrip		char(50);
define _descripcion		char(50);
define _usuario_ing		char(8);
define _usuario_aut		char(8);
define _modulo			char(20);
define _origen			smallint;

-- Produccion
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_factura		char(10);
define _cod_endomov		char(3);
define _tiene_password  smallint;
define _cotizacion		char(10);
define _nueva_renov		char(1);
define _userautoriza	char(8);
define _user_autori     char(8);
define _cot_num         integer;
define _cod_ramo        varchar(3);
define _ramo            char(20);

-- Cobros
define _no_remesa		char(10);
define _tipo_remesa		char(1);
define _renglon			smallint;

-- Reclamos
define _no_tranrec		char(10);
define _transaccion		char(10);
define _cod_tipotran	char(3);
define _wf_apr_j		char(8);
define _wf_apr_jt		char(8);
define _wf_apr_jt_2		char(8);
define _wf_apr_g		char(8);
define _no_reclamo      char(10);

-- Cheques
define _no_requis			char(10);
define _no_cheque			integer;
define _origen_cheque		char(1);
define _fecha_desde			date;
define _fecha_hasta			date;
define _aut_workflow_user	char(8);
define _firma1              char(20);
define _usuario             char(8);

-- Errores
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _cantidad		integer;
	
-- Debito y Credito
define _debito_tmp		dec(16,2);
define _credito_tmp		dec(16,2);


begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

drop table auditoria;

create table auditoria(
sucursal		char(50),
doc_soporte		char(10),
fecha_registro	date,
numero_asiento	integer,
nombre_cuenta	char(50),
cuenta			char(25),
desc_transac	char(50),
fecha_posteo	date,
debito			dec(16,2),
credito			dec(16,2),
tipo_tran		char(50),
drcr			char(2),
usuario_ing		char(8),
usuario_aut		char(8),
modulo			char(20),
ramo            char(20) DEFAULT ""
);

set isolation to dirty read;

let _modulo = "CHEQUES";
let _origen = 4;

let _fecha_desde = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]);
let _fecha_hasta = sp_sis36(a_periodo2);

let _debito_tmp	= 0.00;
let	_credito_tmp = 0.00;

foreach
 select no_requis,
        no_cheque,
        origen_cheque,
		cod_sucursal,
		fecha_anulado,
		anulado_por,
		anulado_por
   into _no_requis,
        _no_cheque,
        _origen_cheque,
		_cod_sucursal,
		_fecha,
		_usuario_ing,
		_usuario_aut
   from chqchmae
  where fecha_anulado >= _fecha_desde
    and fecha_anulado <= _fecha_hasta
	and pagado         = 1
	and anulado        = 1

	select descripcion
	  into _nombre_suc
	  from insagen 
	 where codigo_agencia = _cod_sucursal;
	  
	if _origen_cheque = "1" then
		let _descripcion = "CONTABILIDAD";
	elif _origen_cheque = "2" then
		let _descripcion = "CORREDOR";
	elif _origen_cheque = "3" then
		let _descripcion = "RECLAMOS";
	elif _origen_cheque = "4" then
		let _descripcion = "REASEGURO";
	elif _origen_cheque = "5" then
		let _descripcion = "COASEGURO";
	elif _origen_cheque = "6" then
		let _descripcion = "COBROS";
	elif _origen_cheque = "7" then
		let _descripcion = "HONORARIOS";
	elif _origen_cheque = "8" then
		let _descripcion = "BONIFICACION COBRANZA";
	elif _origen_cheque = "A" then
		let _descripcion = "HONORARIOS SERV. PROFESIONALES";
	elif _origen_cheque = "B" then
		let _descripcion = "SERVICIOS BASICOS";
	elif _origen_cheque = "C" then
		let _descripcion = "ALQUILERES POR ARRENDAMIENTO";
	end if

	foreach
	 select cuenta,
			debito,
			credito,
			tipo
	   into _cuenta,
			_debito,
			_credito,
			_tipo_comp
	   from chqchcta
	  where no_requis = _no_requis
	    and tipo      = 2

		let _con_descrip  = sp_sac11(_origen, _tipo_comp);

		select cta_nombre
		  into _nombre_cuenta
		  from cglcuentas
		 where cta_cuenta = _cuenta;
		  
		foreach
		 select res_notrx,
		        res_fechaact
		   into _notrx,
		        _fechatrx
		   from cglresumen
		  where res_fechatrx         = _fecha
		    and res_cuenta           = _cuenta
			and res_tipcomp          = "004"
			and res_comprobante[8,8] = 2
		  	exit foreach;
		end foreach

		let _debito_tmp	= 0.00;
		let	_credito_tmp = 0.00;

        if _debito < 0 then
			let	_credito_tmp = _debito;
			let _debito = 0;
			let _credito = _credito + _credito_tmp;
		end if
		if _credito > 0 then
			let _debito_tmp	= _credito;
			let _credito = 0;
			let _debito = _debito + _debito_tmp;
		end if
        
		   			
		insert into auditoria(
		sucursal,
		doc_soporte,
		fecha_registro,
		numero_asiento,
		nombre_cuenta,
		cuenta,
		desc_transac,
		fecha_posteo,
		debito,
		credito,
		tipo_tran,
		drcr,
		usuario_ing,
		usuario_aut,
		modulo
		)
		values(
		_nombre_suc,
		_no_cheque,
		_fecha,
		_notrx,
		_nombre_cuenta,
		_cuenta,
		_descripcion,
		_fechatrx,
		_debito,
		_credito,
		_con_descrip,
		"",
		_usuario_ing,
		_usuario_aut,
		_modulo
		);

	end foreach

end foreach

--{
foreach
 select no_requis,
        no_cheque,
        origen_cheque,
		cod_sucursal,
		fecha_impresion,
		user_added,
		autorizado_por,
		firma1,
		aut_workflow_user
   into _no_requis,
        _no_cheque,
        _origen_cheque,
		_cod_sucursal,
		_fecha,
		_usuario_ing,
		_usuario_aut,
		_firma1,
		_aut_workflow_user
   from chqchmae
  where fecha_impresion >= _fecha_desde
    and fecha_impresion <= _fecha_hasta
	and pagado          = 1

	select descripcion
	  into _nombre_suc
	  from insagen 
	 where codigo_agencia = _cod_sucursal;

    if _firma1 Is Not Null And Trim(_firma1) <> "" then
	    select usuario
		  into _usuario
		  from insuser
		 where windows_user = _firma1;
		  
		let _usuario_aut = _usuario;
    elif _aut_workflow_user Is Not Null And Trim(_aut_workflow_user) <> "" then
		let _usuario_aut = _aut_workflow_user;
	end if
	  
	if _origen_cheque = "1" then
		let _descripcion = "CONTABILIDAD";
	elif _origen_cheque = "2" then
		let _descripcion = "CORREDOR";
	elif _origen_cheque = "3" then
		let _descripcion = "RECLAMOS";
	elif _origen_cheque = "4" then
		let _descripcion = "REASEGURO";
	elif _origen_cheque = "5" then
		let _descripcion = "COASEGURO";
	elif _origen_cheque = "6" then
		let _descripcion = "COBROS";
	elif _origen_cheque = "7" then
		let _descripcion = "HONORARIOS";
	elif _origen_cheque = "8" then
		let _descripcion = "BONIFICACION COBRANZA";
	elif _origen_cheque = "A" then
		let _descripcion = "HONORARIOS SERV. PROFESIONALES";
	elif _origen_cheque = "B" then
		let _descripcion = "SERVICIOS BASICOS";
	elif _origen_cheque = "C" then
		let _descripcion = "ALQUILERES POR ARRENDAMIENTO";
	end if

	foreach
	 select cuenta,
			debito,
			credito,
			tipo
	   into _cuenta,
			_debito,
			_credito,
			_tipo_comp
	   from chqchcta
	  where no_requis = _no_requis
	    and tipo      = 1

		let _con_descrip  = sp_sac11(_origen, _tipo_comp);

		select cta_nombre
		  into _nombre_cuenta
		  from cglcuentas
		 where cta_cuenta = _cuenta;
		  
		foreach
		 select res_notrx,
		        res_fechaact
		   into _notrx,
		        _fechatrx
		   from cglresumen
		  where res_fechatrx         = _fecha
		    and res_cuenta           = _cuenta
			and res_tipcomp          = "004"
			and res_comprobante[8,8] = 1
		  	exit foreach;
		end foreach

		let _debito_tmp	= 0.00;
		let	_credito_tmp = 0.00;

        if _debito < 0 then
			let	_credito_tmp = _debito;
			let _debito = 0;
			let _credito = _credito + _credito_tmp;
		end if
		if _credito > 0 then
			let _debito_tmp	= _credito;
			let _credito = 0;
			let _debito = _debito + _debito_tmp;
		end if
		   			
		insert into auditoria(
		sucursal,
		doc_soporte,
		fecha_registro,
		numero_asiento,
		nombre_cuenta,
		cuenta,
		desc_transac,
		fecha_posteo,
		debito,
		credito,
		tipo_tran,
		drcr,
		usuario_ing,
		usuario_aut,
		modulo
		)
		values(
		_nombre_suc,
		_no_cheque,
		_fecha,
		_notrx,
		_nombre_cuenta,
		_cuenta,
		_descripcion,
		_fechatrx,
		_debito,
		_credito,
		_con_descrip,
		"",
		_usuario_ing,
		_usuario_aut,
		_modulo
		);

	end foreach

end foreach
--}
--{
let _modulo = "RECLAMOS";
let _origen = 2;

foreach
 select no_tranrec,
        transaccion,
        cod_tipotran,
		cod_sucursal,
		fecha,
		user_added,
		user_added,
		wf_apr_j,
		wf_apr_jt,
		wf_apr_jt_2,
		wf_apr_g,
		no_reclamo
   into _no_tranrec,
        _transaccion,
        _cod_tipotran,
		_cod_sucursal,
		_fecha,
		_usuario_ing,
		_usuario_aut,
		_wf_apr_j,
		_wf_apr_jt,
		_wf_apr_jt_2,
		_wf_apr_g,
		_no_reclamo
   from rectrmae
  where periodo    >= a_periodo1
    and periodo    <= a_periodo2
	and actualizado = 1

	select descripcion
	  into _nombre_suc
	  from insagen 
	 where codigo_agencia = _cod_sucursal;
	  
	select nombre
	  into _descripcion 
	  from rectitra
	 where cod_tipotran = _cod_tipotran;

    select numrecla[1,2]
	  into _cod_ramo
	  from recrcmae
	 where no_reclamo = _no_reclamo;

     let _cod_ramo = "0" || trim(_cod_ramo);

    select nombre
	  into _ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

    if _wf_apr_g Is Not Null And Trim(_wf_apr_g) <> "" then
		let _usuario_aut = _wf_apr_g;
	elif _wf_apr_jt_2 Is Not Null And Trim(_wf_apr_jt_2) <> "" then
		let _usuario_aut = _wf_apr_jt_2;
	elif _wf_apr_jt Is Not Null And Trim(_wf_apr_jt) <> "" then
		let _usuario_aut = _wf_apr_jt;
	elif _wf_apr_j Is Not Null And Trim(_wf_apr_j) <> "" then
		let _usuario_aut = _wf_apr_j;
	end if


	foreach
	 select sac_notrx,
	        cuenta,
			debito,
			credito,
			tipo_comp
	   into _notrx,
	        _cuenta,
			_debito,
			_credito,
			_tipo_comp
	   from recasien
	  where no_tranrec = _no_tranrec

		let _con_descrip  = sp_sac11(_origen, _tipo_comp);

		select cta_nombre
		  into _nombre_cuenta
		  from cglcuentas
		 where cta_cuenta = _cuenta;
		  
		foreach
		 select res_fechatrx
		   into _fechatrx
		   from cglresumen
		  where res_notrx  = _notrx
		    and res_cuenta = _cuenta
		  	exit foreach;
		end foreach

		let _debito_tmp	= 0.00;
		let	_credito_tmp = 0.00;

        if _debito < 0 then
			let	_credito_tmp = _debito;
			let _debito = 0;
			let _credito = _credito + _credito_tmp;
		end if
		if _credito > 0 then
			let _debito_tmp	= _credito;
			let _credito = 0;
			let _debito = _debito + _debito_tmp;
		end if
		   			
		insert into auditoria(
		sucursal,
		doc_soporte,
		fecha_registro,
		numero_asiento,
		nombre_cuenta,
		cuenta,
		desc_transac,
		fecha_posteo,
		debito,
		credito,
		tipo_tran,
		drcr,
		usuario_ing,
		usuario_aut,
		modulo,
		ramo
		)
		values(
		_nombre_suc,
		_transaccion,
		_fecha,
		_notrx,
		_nombre_cuenta,
		_cuenta,
		_descripcion,
		_fechatrx,
		_debito,
		_credito,
		_con_descrip,
		"",
		_usuario_ing,
		_usuario_aut,
		_modulo,
		_ramo
		);

	end foreach

end foreach
--}
--{
let _modulo = "COBROS";
let _origen = 3;

foreach
 select no_remesa,
        tipo_remesa,
		cod_sucursal,
		fecha,
		user_added,
		user_posteo
   into _no_remesa,
        _tipo_remesa,
		_cod_sucursal,
		_fecha,
		_usuario_ing,
		_usuario_aut
   from cobremae
  where periodo    >= a_periodo1
    and periodo    <= a_periodo2
	and actualizado = 1

	select descripcion
	  into _nombre_suc
	  from insagen 
	 where codigo_agencia = _cod_sucursal;
	  
	if _tipo_remesa = "A" then
	   let _descripcion = "RECIBO AUTOMATICO";
	elif _tipo_remesa = "M" then
	   let _descripcion = "RECIBO MANUAL";
	elif _tipo_remesa = "C" then
	   let _descripcion = "COMPROBANTES";
	elif _tipo_remesa = "F" then
	   let _descripcion = "FLUJO CAJA";
	elif _tipo_remesa = "T" then
	   let _descripcion = "AJUSTE CENTAVOS";
	end if

	foreach
	 select renglon,
	        no_recibo
	   into _renglon,
	        _no_factura
	   from cobredet
	  where no_remesa = _no_remesa

		foreach
		 select sac_notrx,
		        cuenta,
				debito,
				credito,
				tipo_comp
		   into _notrx,
		        _cuenta,
				_debito,
				_credito,
				_tipo_comp
		   from cobasien
		  where no_remesa = _no_remesa
		    and renglon   = _renglon

			let _con_descrip  = sp_sac11(_origen, _tipo_comp);

			select cta_nombre
			  into _nombre_cuenta
			  from cglcuentas
			 where cta_cuenta = _cuenta;
			  
			foreach
			 select res_fechatrx
			   into _fechatrx
			   from cglresumen
			  where res_notrx  = _notrx
			    and res_cuenta = _cuenta
			  	exit foreach;
			end foreach

			let _debito_tmp	= 0.00;
			let	_credito_tmp = 0.00;

	        if _debito < 0 then
				let	_credito_tmp = _debito;
				let _debito = 0;
				let _credito = _credito + _credito_tmp;
			end if
			if _credito > 0 then
				let _debito_tmp	= _credito;
				let _credito = 0;
				let _debito = _debito + _debito_tmp;
			end if
			   			
			insert into auditoria(
			sucursal,
			doc_soporte,
			fecha_registro,
			numero_asiento,
			nombre_cuenta,
			cuenta,
			desc_transac,
			fecha_posteo,
			debito,
			credito,
			tipo_tran,
			drcr,
			usuario_ing,
			usuario_aut,
			modulo
			)
			values(
			_nombre_suc,
			_no_factura,
			_fecha,
			_notrx,
			_nombre_cuenta,
			_cuenta,
			_descripcion,
			_fechatrx,
			_debito,
			_credito,
			_con_descrip,
			"",
			_usuario_ing,
			_usuario_aut,
			_modulo
			);

		end foreach

	end foreach

end foreach

--}
--{
let _modulo = "PRODUCCION";
let _origen = 1;

foreach
 select no_poliza,
        no_endoso,
		no_factura,
		cod_endomov,
		cod_sucursal,
		fecha_impresion,
		user_added,
		user_added
   into _no_poliza,
        _no_endoso,
		_no_factura,
		_cod_endomov,
		_cod_sucursal,
		_fecha,
		_usuario_ing,
		_usuario_aut
   from endedmae
  where periodo    >= a_periodo1
    and periodo    <= a_periodo2
	and actualizado = 1

	select descripcion
	  into _nombre_suc
	  from insagen 
	 where codigo_agencia = _cod_sucursal;
	  
	select nombre,
	       tiene_password
	  into _descripcion,
	       _tiene_password
	  from endtimov
	 where cod_endomov = _cod_endomov;

    select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

    select nombre
	  into _ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

    if _no_endoso = "00000" then
		select cotizacion,
		       nueva_renov
		  into _cotizacion,
		       _nueva_renov
		  from emipomae
		 where no_poliza = _no_poliza;

    	if _cotizacion Is Not Null And Trim(_cotizacion) <> "" And _nueva_renov = 'N' then
			let _cot_num = _cotizacion;
			select userautoriza
			  into _userautoriza
			  from wf_cotizacion
			 where nrocotizacion = _cot_num;

            if _userautoriza Is Not Null And Trim(_userautoriza) <> "" then 
				let _usuario_aut = _userautoriza;
			end if
		end if
	end if

    if _no_endoso <> "00000" And _tiene_password = 1 then
		select user_autori 
		  into _user_autori 
		  from endbiaut
		 where no_poliza   = _no_poliza
		   and no_endoso   = _no_endoso;

        if _user_autori Is Not Null And Trim(_user_autori) <> "" then 
			let _usuario_aut = _user_autori;
		end if
	end if
		
	foreach
	 select sac_notrx,
	        cuenta,
			debito,
			credito,
			tipo_comp
	   into _notrx,
	        _cuenta,
			_debito,
			_credito,
			_tipo_comp
	   from endasien
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		let _con_descrip  = sp_sac11(_origen, _tipo_comp);

		select cta_nombre
		  into _nombre_cuenta
		  from cglcuentas
		 where cta_cuenta = _cuenta;
		  
		foreach
		 select res_fechatrx
		   into _fechatrx
		   from cglresumen
		  where res_notrx  = _notrx
		    and res_cuenta = _cuenta
		  	exit foreach;
		end foreach

		let _debito_tmp	= 0.00;
		let	_credito_tmp = 0.00;

        if _debito < 0 then
			let	_credito_tmp = _debito;
			let _debito = 0;
			let _credito = _credito + _credito_tmp;
		end if
		if _credito > 0 then
			let _debito_tmp	= _credito;
			let _credito = 0;
			let _debito = _debito + _debito_tmp;
		end if      
		   			
		insert into auditoria(
		sucursal,
		doc_soporte,
		fecha_registro,
		numero_asiento,
		nombre_cuenta,
		cuenta,
		desc_transac,
		fecha_posteo,
		debito,
		credito,
		tipo_tran,
		drcr,
		usuario_ing,
		usuario_aut,
		modulo,
		ramo
		)
		values(
		_nombre_suc,
		_no_factura,
		_fecha,
		_notrx,
		_nombre_cuenta,
		_cuenta,
		_descripcion,
		_fechatrx,
		_debito,
		_credito,
		_con_descrip,
		"",
		_usuario_ing,
		_usuario_aut,
		_modulo,
		_ramo
		);

	end foreach

end foreach
--}

end

--unload to 'auditoria.txt' delimiter '|'  select * from auditoria;

select count(*)
  into _cantidad
  from auditoria;

return _cantidad, "  Actualizacion Exitosa";


end procedure