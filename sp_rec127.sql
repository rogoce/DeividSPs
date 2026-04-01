-- Procedimiento que Realiza la anulacion automatica de N/T.

-- Creado    : 24/08/2006 - Autor: Armando Moreno M.

drop procedure sp_rec127;
create procedure sp_rec127(
a_compania   		char(3), 
a_sucursal   		char(3), 
a_no_reclamo 		char(10),
a_valor_ant       	char(10),
a_valor_nvo		  	char(10),
a_user			  	char(10))
returning	integer,
			char(100);

define _mensaje				varchar(100);
define _desc				varchar(50);
define _transaccion,_no_reclamo			char(10);
define _tran_nvo,_no_poliza			char(10);
define v_periodo			char(7);
define _cod_cober,_cod_contrato			char(5);
define _cod_chequera		char(3);
define _cod_banco,_cod_ramo			char(3);
define _origen_cheque		char(1);
define _monto_cober			dec(16,2);
define _valor_parametro		integer;
define _no_cheque			integer;
define _resultado			integer;
define _error				integer;
define _firma_electronica	smallint;
define _wf_aprobado			smallint;
define _actualizado			smallint;
define _pagado_nt			smallint;
define _renglon				smallint;
define _wf_incidente		integer;
define _cuantos				integer;
define _fecha_actual		date;
define ld_hoy				date;

--SET DEBUG FILE TO "sp_rec127.trc"; 
--trace on;

begin

on exception set _error 
 	return _error,"";         
end exception

set lock mode to wait;

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
	let _pagado_nt	 = 1;

	update rectrmae
	   set pagado         = 1,
	   	   user_anulo     = a_user,
		   fecha_anulo    = _fecha_actual,
		   anular_nt      = _tran_nvo,
		   no_requis      = null,
		   generar_cheque = 0
	 where no_tranrec     = a_valor_ant;
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

update rectrmae
   set no_requis         = null,
	   actualizado       = _actualizado,
       fecha		     = _fecha_actual,
	   pagado            = _pagado_nt,
	   transaccion       = _tran_nvo,
	   anular_nt         = _transaccion,
	   monto             = monto * -1,
	   variacion	     = 0,
	   periodo           = v_periodo,
	   generar_cheque    = 0,
	   user_added        = a_user,
	   facturado	     = facturado * -1,	
	   elegible		     = elegible * -1,	
	   a_deducible	     = a_deducible * -1,	
	   co_pago		     = co_pago * -1,	
	   monto_no_cubierto = monto_no_cubierto * -1,	
	   coaseguro		 = coaseguro * -1,	
	   ahorro			 = ahorro * -1,
	   incurrido_total   = incurrido_total * -1,
	   incurrido_bruto   = incurrido_bruto * -1,
	   incurrido_neto    = incurrido_neto  * -1,
	   pagado_proveedor  = pagado_proveedor * -1,
	   pagado_taller     = pagado_taller * -1, 
	   pagado_asegurado  = pagado_asegurado * -1,  
	   pagado_tercero    = pagado_tercero * -1,  
	   user_anulo        = a_user,
	   fecha_anulo       = _fecha_actual,
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
	   sac_asientos      = 0
 where no_tranrec        = a_valor_nvo;

-- Reaseguro de los Reclamos para los Asientos

if _actualizado = 1 then

	call sp_rea008(3, a_valor_nvo) returning _error, _mensaje;

	if _error <> 0 then
		return _error, _mensaje;
	end if

end if

------------------
select * 
  from rectrcon
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;

insert into rectrcon
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

update rectrcon
   set monto       = monto * -1  
 where no_tranrec  = a_valor_nvo;

drop table prueba;
------------------
select * 
  from rectrcob
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;

insert into rectrcob
select * 
  from prueba
 where no_tranrec = a_valor_nvo;

update rectrcob
   set monto             = monto * -1,
	   variacion         = 0,
	   facturado   		 = facturado * -1,
	   elegible	         = elegible * -1,
	   a_deducible       = a_deducible * -1,
	   co_pago	         = co_pago * -1,
	   monto_no_cubierto = monto_no_cubierto * -1,
	   coaseguro         = coaseguro * -1,
	   ahorro			 = ahorro * -1
 where no_tranrec        = a_valor_nvo;

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
------------------
select * 
  from rectrde2
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba 
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;

select max(renglon)
  into _renglon
  from prueba
 where no_tranrec = a_valor_nvo;

let _renglon = _renglon + 1;

let _desc = 'PARA ANULAR N/T#: '|| _transaccion;

insert into prueba(
no_tranrec,
renglon,
desc_transaccion
)
VALUES(
a_valor_nvo,
_renglon,
_desc
);

select count(*)
  into _cuantos
  from rectrde2
 where no_tranrec = a_valor_ant;

if _cuantos > 0 then
	insert into rectrde2
	select * 
	  from prueba
	 where no_tranrec = a_valor_nvo;
end if

drop table prueba;
------------------
select * 
  from rectrrea
 where no_tranrec = a_valor_ant
  into temp prueba;

update prueba
   set no_tranrec = a_valor_nvo
 where no_tranrec = a_valor_ant;
 
 select no_reclamo
   into _no_reclamo
   from rectrmae
  where no_tranrec = a_valor_ant;
  
 select no_poliza
   into _no_poliza
   from recrcmae
  where no_reclamo = _no_reclamo;
  
 select cod_ramo
   into _cod_ramo
   from emipomae
  where actualizado = 1
    and no_poliza = _no_poliza;
 
 --Cuando se anula una transaccion de estos ramos, hay que hacer el cambio de los contratos por el traspaso de cartera hecho en julio 2024 patrimoniales de munich a allied
 --subido 29/07/2024 1:50 pm, AMM. 
 if _cod_ramo in('001','003','006','010','011','012','013','014','021','022') then
  
	 foreach
			select cod_contrato
			  into _cod_contrato
			  from prueba
			  
			if _cod_contrato = '00750' then
				update prueba
				   set cod_contrato = '00775'
				 where cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00755' then
				update prueba
				   set cod_contrato = '00776'
				 where cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00751' then
				update prueba
				   set cod_contrato = '00777'
				 where cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00756' then
				update prueba
				   set cod_contrato = '00778'
				 where cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00752' then
				update prueba
				   set cod_contrato = '00779'
				 where cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00757' then
				update prueba
				   set cod_contrato = '00780'
				 where cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00753' then
				update prueba
				   set cod_contrato = '00781'
				 where cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00758' then
				update prueba
				   set cod_contrato = '00782'
				 where cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00754' then
				update prueba
				   set cod_contrato = '00783'
				 where cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00759' then
				update prueba
				   set cod_contrato = '00784'
				 where cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00746' then
				update prueba
				   set cod_contrato = '00785'
				 where cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00745' then
				update prueba
				   set cod_contrato = '00786'
				 where cod_contrato = _cod_contrato;
			end if
	end foreach
end if

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