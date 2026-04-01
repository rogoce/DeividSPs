-- Reporte de las Comisiones por Corredor - Totales para info de la super.
-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - d_cheq_sp_che04_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_che04a;
CREATE PROCEDURE sp_che04a(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha_desde DATE, a_fecha_hasta DATE, a_verif_tipo_pago SMALLINT DEFAULT 0) 
RETURNING   smallint;

DEFINE v_nombre_agt   CHAR(50);
DEFINE v_monto        DEC(16,2);
DEFINE v_prima        DEC(16,2);
DEFINE v_comision     DEC(16,2);
DEFINE v_no_licencia  CHAR(10);
DEFINE v_monto_vida   DEC(16,2);
DEFINE v_monto_danos  DEC(16,2);
DEFINE v_monto_fianza DEC(16,2);
DEFINE v_arrastre	  DEC(16,2);
DEFINE _cod_agente    CHAR(5);
DEFINE _fecha_ult_comis DATE;  
DEFINE _tipo_pago     SMALLINT; 
DEFINE _tipo_agente   CHAR(1);  
DEFINE v_comision2    DEC(16,2);
define _no_recibo		char(10);
define v_no_recibo		char(10);
define _fecha_recibo	date;
define _no_poliza		char(10);
define _no_documento	char(21);
define _cnt_existe		smallint;
define _comision_adelanto	dec(16,2);
define _no_requis		char(10);
define _tipo_requis     char(1);
define _mto_bono        decimal(16,2);

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_agente;

CALL sp_che02(
a_compania, 
a_sucursal,
a_fecha_desde,
a_fecha_hasta,
0,
a_verif_tipo_pago
);

foreach
	select a.cod_agente,
		   a.no_recibo,
		   a.no_poliza,
		   a.no_documento,
		   a.fecha
	  into _cod_agente,
		   v_no_recibo,
		   _no_poliza,
		   _no_documento,
		   _fecha_recibo
	  from tmp_agente a
	 where a.seleccionado = 1

	let  _cod_agente = _cod_agente; 
	let  v_no_recibo = v_no_recibo; 
	let  _no_poliza = _no_poliza ;
	let  _no_documento = _no_documento ;
	let  _fecha_recibo = _fecha_recibo;
	let _mto_bono      = 0;

	let _cnt_existe = 0;
	   
   	if _no_poliza <> '00000' then
		select count(*)
		  into _cnt_existe
		  from cobadeco																			 
		 where cod_agente	= _cod_agente
		   and no_documento = _no_documento;

		if _cnt_existe is null then
			let _cnt_existe = 0;
		end if

		if _cnt_existe <> 0 or _no_documento in ('0214-03842-01','0212-02539-01','1808-00589-01') then
			select comision_adelanto,
				   no_recibo
			  into _comision_adelanto,
			  	   _no_recibo
			  from cobadeco
			 where cod_agente	= _cod_agente
			   and no_documento = _no_documento;
			   
			if v_no_recibo = _no_recibo then
				let v_comision			= _comision_adelanto;
			else
				let v_comision			= 0.00; 
			end if
			
			update tmp_agente
			   set comision = v_comision
			 where cod_agente	= _cod_agente
			   and no_poliza	= _no_poliza
			   and no_recibo	= v_no_recibo
			   and fecha		= _fecha_recibo;
		
		else
			if _no_documento <> '0213-00946-04' then
				select count(*)
				  into _cnt_existe
				  from cobadecoh
				 where no_documento = _no_documento 
				   and cod_agente	= _cod_agente
				   and fecha >= _fecha_recibo
				   and poliza_cancelada = 1;

				if _cnt_existe > 0 then
					select comision_adelanto,
						   no_recibo
					  into _comision_adelanto,
						   _no_recibo
					  from cobadecoh
					 where cod_agente	= _cod_agente
					   and no_documento = _no_documento
					   and fecha >= _fecha_recibo;

					if v_no_recibo = _no_recibo then
						let v_comision			= _comision_adelanto;
					else
						let v_comision			= 0.00; 
					end if
					
					update tmp_agente
					   set comision     = v_comision
					 where cod_agente	= _cod_agente
					   and no_poliza	= _no_poliza
					   and no_recibo	= v_no_recibo
					   and fecha		= _fecha_recibo;
				end if
			end if
		end if
	end if 		
end foreach

return 0;
END PROCEDURE;