-- Procedimiento que Crea los Registros para los Auditores - Deloitte
-- 
-- Creado     : 29/10/2008 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud14;

create procedure "informix".sp_aud14(
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
define _cot_num         dec;

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

-- Cheques
define _no_requis			char(10);
define _no_cheque			integer;
define _origen_cheque		char(1);
define _fecha_desde			date;
define _fecha_hasta			date;
define _aut_workflow_user	char(8);

-- Errores
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _cantidad		integer;
	
begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc || " " || _no_poliza || " " || _no_endoso;
end exception

set isolation to dirty read;
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
--}

end

select count(*)
  into _cantidad
  from auditoria;

return _cantidad, "  Actualizacion Exitosa";

--unload to facturas.txt select * from tmp_facturas;

end procedure