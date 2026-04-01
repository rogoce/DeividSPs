-- Procedimiento que Crea N/T a partir de una.

-- Creado    : 15/05/2025 - Autor: Armando Moreno M.

drop procedure sp_rec322;
create procedure sp_rec322(
a_compania   		char(3), 
a_sucursal   		char(3), 
a_no_reclamo 		char(10),
a_valor_ant       	char(10),
a_valor_nvo		  	char(10),
a_user			  	char(10),
a_cod_cobertura     char(5),
a_cod_asignacion    char(10),
a_renglon           smallint)
returning	integer,
			char(100);

define _mensaje				varchar(100);
define _desc				varchar(50);
define _transaccion,_no_reclamo,_no_factura,_no_requis	char(10);
define _tran_nvo,_no_poliza,_cod_cpt			char(10);
define v_periodo			char(7);
define _cod_cober,_cod_contrato			char(5);
define _cod_chequera		char(3);
define _cod_banco,_cod_ramo			char(3);
define _origen_cheque		char(1);
define _monto_cober,_variacion,_reserva_actual			dec(16,2);
define _valor_parametro		integer;
define _no_cheque			integer;
define _resultado			integer;
define _error				integer;
define _firma_electronica	smallint;
define _wf_aprobado			smallint;
define _actualizado			smallint;
define _pagado_nt,_valor			smallint;
define _renglon,_generar_cheque				smallint;
define _wf_incidente		integer;
define _cuantos				integer;
define _fecha_actual		date;
define ld_hoy,_fecha_factura date;


--SET DEBUG FILE TO "sp_rec322.trc"; 
--trace on;

begin

on exception set _error 
 	return _error,"";         
end exception

set lock mode to wait;

LET a_valor_nvo = sp_sis13('001',"REC","02","par_tran_genera");

IF a_valor_nvo IS NULL OR a_valor_nvo = "" OR a_valor_nvo = "00000" THEN
	RETURN 1, "Error al generar # transaccion interno, verifique...";
END IF

select valor_parametro
  into _valor_parametro
  from inspaag
 where codigo_compania  = a_compania
   and aplicacion       = "REC"
   and inspaag.version  = "02"
   and codigo_parametro = "fecha_recl_default";

if _valor_parametro = 1 then      --fecha proveniente del servidor
	let _fecha_actual = current;
else
	select valor_parametro
	  into _fecha_actual
	  from inspaag
	 where codigo_compania  = a_compania
	   and aplicacion       = "REC"
	   and inspaag.version  = "02"
	   and codigo_parametro = "fecha_recl_valor";
end if

if month(_fecha_actual) < 10 then
	let v_periodo = year(_fecha_actual) || '-0' || month(_fecha_actual);
else
	let v_periodo = year(_fecha_actual) || '-' || month(_fecha_actual);
end if

let _reserva_actual = 0.00;

select reserva_actual
  into _reserva_actual
  from recrcmae
 where no_reclamo = a_no_reclamo; 
  
select wf_aprobado,
       wf_incidente,
	   transaccion
  into _wf_aprobado,
       _wf_incidente,
	   _transaccion
  from rectrmae
 where no_tranrec = a_valor_ant;

if a_user = "GERENCIA" or a_user = 'ARMANDO' then
	let _wf_aprobado = 0;
end if

if _wf_aprobado = 1 and (_wf_incidente is not null or _wf_incidente <> "") then --debe ir a aprobacion
	let _tran_nvo    = null;
	let _actualizado = 0;
	let _pagado_nt   = 0;
else
	let _tran_nvo = sp_sis12(a_compania,a_sucursal,a_no_reclamo);
	let _tran_nvo = trim(_tran_nvo);
	let _actualizado = 1;
	let _pagado_nt	 = 0;
end if

select * 
  from rectrmae
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;

insert into rectrmae
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

drop table prueba;

let _monto_cober = 0;
let _variacion   = 0;

select monto,
       variacion,
	   fecha_factura,
	   cod_cpt,
	   no_factura
  into _monto_cober,
       _variacion,
	   _fecha_factura,
	   _cod_cpt,
	   _no_factura
  from rectrcobt
 where no_tranrec    = a_valor_ant
   and cod_cobertura = a_cod_cobertura
   and renglon       = a_renglon;
   
let _generar_cheque = 0;
if _monto_cober > 0 then
	let _generar_cheque = 1;
end if	
   
 update rectrmae
   set no_requis         = null,
	   actualizado       = _actualizado,
       fecha		     = _fecha_actual,
	   fecha_factura     = _fecha_factura,
	   cod_cpt           = _cod_cpt,
	   no_factura        = _no_factura,
	   pagado            = _pagado_nt,
	   transaccion       = _tran_nvo,
	   anular_nt         = null,
	   monto             = _monto_cober,
	   variacion	     = _variacion,
	   periodo           = v_periodo,
	   generar_cheque    = _generar_cheque,
	   user_added        = a_user,
	   wf_incidente		 = null,
	   wf_aprobado		 = 2,
	   wf_apr_js		 = null,
	   wf_apr_js_fh		 = null,
	   wf_apr_j			 = null,
	   wf_apr_j_fh		 = null,
	   wf_apr_jt		 = null,
	   wf_apr_jt_fh		 = null,
	   wf_apr_g			 = null,
	   wf_apr_g_fh		 = null,
	   wf_inc_auto		 = null,
	   wf_ord_com		 = null,
	   wf_inc_padre		 = null,
	   wf_apr_jt_2		 = null,
	   wf_apr_jt_2_fh    = null,
	   sac_asientos      = 0,
	   cod_asignacion    = a_cod_asignacion
 where no_tranrec        = a_valor_nvo;

-- Reaseguro de los Reclamos para los Asientos

if _actualizado = 1 then

	call sp_rea008(3, a_valor_nvo) returning _error, _mensaje;

	if _error <> 0 then
		return _error, _mensaje;
	end if
	if _generar_cheque = 1 then
		call sp_rec293(a_valor_nvo,_tran_nvo) returning _resultado, _mensaje, _no_requis;
		if _resultado = 0 THEN
			update rectrmae
			   set no_requis = _no_requis
			 where no_tranrec = a_valor_nvo;
		else
			return _resultado, _mensaje;
		end if
	end if
end if
if abs(_variacion) > abs(_reserva_actual) then
	return 13,"";
else
	Update recrcmae
	   Set reserva_actual = reserva_actual + _variacion
	 Where no_reclamo     = a_no_reclamo;
end if

select reserva_actual
  into _reserva_actual
  from recrccob
 where no_reclamo    = a_no_reclamo
   and cod_cobertura = a_cod_cobertura;
   
if abs(_variacion) > abs(_reserva_actual) then
	return 13,"";
else
	Update recrccob
	   Set pagos = pagos + _monto_cober,
		   reserva_actual = reserva_actual + _reserva_actual
	 Where no_reclamo    = a_no_reclamo
	   And cod_cobertura = a_cod_cobertura;
end if
------------------
select * 
  from rectrcon
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo,
       monto      = _monto_cober
 where no_tranrec = a_valor_ant;

insert into rectrcon
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

update rectrcon
   set monto       = monto
 where no_tranrec  = a_valor_nvo;

drop table prueba;
------------------
select no_tranrec,
       cod_cobertura,
       monto, 
       variacion,
       facturado,
       elegible,
       a_deducible,
       co_pago,
       cod_no_cubierto,
       monto_no_cubierto,
       cod_tipo,
       coaseguro,
       ahorro,
       descripcion,
       subir_bo
   from rectrcobt
 where no_tranrec    = a_valor_ant
   and cod_cobertura = a_cod_cobertura
   and renglon       = a_renglon
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;

insert into rectrcob
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

drop table prueba;

-- solo actualizar los pago cuando la variable en _actualizado sea 1 -- casos de auditoría 03/10/2019 diferencias entre recrcob y rectrcob en pagos
if _actualizado = 1 then
	foreach
	  select monto,
			 cod_cobertura
		into _monto_cober,
			 _cod_cober
		from rectrcob
	   where no_tranrec = a_valor_nvo

		Update recrccob
		   Set pagos = pagos + _monto_cober
		 Where no_reclamo    = a_no_reclamo
		   And cod_cobertura = _cod_cober;
	  
	end foreach
end if
------------------acumulaciones de la primas de salud
if _actualizado = 1 then
	CALL sp_rec56(a_compania,a_valor_nvo) RETURNING _resultado,_mensaje;

	if _mensaje is null then
		let _mensaje = "";
	end if 
	If _resultado <> 0 Then
		Return 1,_mensaje;
	End If
end if
------------------Descripcion de la N/T
let _valor = sp_rec62bb(a_no_reclamo, a_valor_nvo);
------------------
select * 
  from rectrrea
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;
 
insert into rectrrea
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

drop table prueba;
------------------
select * 
  from rectrref
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;

insert into rectrref
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

drop table prueba;
------------------
-- Reaseguro a Nivel de Transaccion
call sp_sis58(a_valor_nvo) returning _resultado, _mensaje;
if _resultado <> 0 THEN
	return 14,_mensaje;
end IF
-- Procedimiento que Genera el Recibo de Pago de los Movimientos de Reclamos de Primas Pendientes
 
if _actualizado = 1 then

	call sp_rec197(a_valor_nvo) returning _error, _mensaje;

	if _error <> 0 then
		return _error, _mensaje;
	end if

end if

return 0,_tran_nvo;
END
end procedure