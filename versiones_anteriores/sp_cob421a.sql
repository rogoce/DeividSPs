-- Procedimiento carga ducruet (sucursal 091)
-- Creado : 07/06/2017 - Autor: Henry Giron  
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob421;
create procedure "informix".sp_cob421(a_numero 	char(10))
returning	integer,char(100);

define _error_desc			varchar(100);
define _no_documento		char(20);
define _no_recibo_det		integer;
define _no_remesa			char(10);
define _cero                char(1);
define _monto_cobrado_det	dec(16,2);
define _monto_comis_det		dec(16,2);
define _monto_bruto_det		dec(16,2);
define _error_isam			integer;
define _secuencia           integer;
define _error				integer;
define _no_remesa_int       integer;

define _valor_parametro	char(15);
define _valor_int		integer;
define _valor_char		char(10);
define _comis_cobro	    dec(16,2);
define _comis_visa		dec(16,2);
define _comis_clave		dec(16,2);

	   		   

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
  return _error,_error_desc;
end exception

--return 0,'Desactivado';

{select valor_parametro
  into _valor_parametro
  from parcont
 where cod_compania  = '001'
   and aplicacion    = 'COB'
   and version       = '02'
   and cod_parametro = 'par_numero';

let _valor_int  = _valor_parametro;
let _valor_int  = _valor_int + 1;
let _valor_char = '00000';

IF _valor_int > 9999  THEN
	LET _valor_char       = _valor_int;
ELIF _valor_int > 999 THEN
	LET _valor_char[2,5] = _valor_int;
ELIF _valor_int > 99  THEN
	LET _valor_char[3,5] = _valor_int;
ELIF _valor_int > 9   THEN
	LET _valor_char[4,5] = _valor_int;
ELSE
	LET _valor_char[5,5] = _valor_int;
END IF}


-- creaion de remesa de pago externo 00035 y 02656
select *	     
  from cobpaex0
 where numero = a_numero
  into temp tmp1_cobpaex0; 
 
 select *	     
  from cobpaex1
 where numero = a_numero
  into temp tmp1_cobpaex1;     
  
select *	     
  from cobpaex0
 where numero = a_numero
  into temp tmp2_cobpaex0; 
 
 select *	     
  from cobpaex1
 where numero = a_numero
  into temp tmp2_cobpaex1;    
  
--usuario	cod_agente	no_remesa	fecha_remesa	monto_total	monto_comis	monto_comis_cobro	monto_comis_visa	monto_comis_clave	monto_bruto	no_cheque	periodo_desde	periodo_hasta	insertado_remesa	no_recibo_ancon	fecha_recibo	no_remesa_ancon	tipo_formato  

select sum(monto_bruto),
		sum(monto_cobrado),
		sum(monto_comis),
		sum(comis_cobro),
		sum(comis_visa),
		sum(comis_clave)
	into _monto_bruto_det,
	   _monto_cobrado_det,
	   _monto_comis_det,	
	   _comis_cobro,
	   _comis_visa,
	   _comis_clave,		
	from tmp1_cobpaex1;
	  
  
 select	numero,
	fecha_adicion,
	usuario,
	cod_agente,
	no_remesa,
	fecha_remesa,
	monto_total,
	monto_comis,
	monto_comis_cobro,
	monto_comis_visa,
	monto_comis_clave,
	monto_bruto,
	no_cheque,
	periodo_desde,
	periodo_hasta,
	no_recibo_ancon,
	fecha_recibo,
	tipo_formato
into numero,
	fecha_adicion,
	usuario,
	cod_agente,
	no_remesa,
	fecha_remesa,
	monto_total,
	monto_comis,
	monto_comis_cobro,
	monto_comis_visa,
	monto_comis_clave,
	monto_bruto,
	no_cheque,
	periodo_desde,
	periodo_hasta,
	no_recibo_ancon,
	fecha_recibo,
	tipo_formato
from tmp_cobpaex0
where numero = a_numero ;
  
  
  	  Insert Into cobpaex0 (numero,
	            fecha_adicion,
				usuario,
				cod_agente,
				no_remesa,
				fecha_remesa,
				monto_total,
				monto_comis,
				monto_comis_cobro,
				monto_comis_visa,
				monto_comis_clave,
				monto_bruto,
				no_cheque,
				periodo_desde,
				periodo_hasta,
				no_recibo_ancon,
				fecha_recibo,
				tipo_formato)
	Values     (_numero,
	_fecha,
	a_usuario,
	'00035',
	_numero_rem_agt,
	_fecha_rem,
	_monto_t_rem,
	_monto_t_com,
	_monto_t_com_cob,
	_monto_t_com_vis,
	_monto_t_com_clve,
	_monto_b_rem,
	_no_cheque,
	_periodo_desde,
	_periodo_hasta,
	_no_recibo_ancon,
	_fecha,
	_tipo_formato);					  
 
 let _error_desc	= "";
 let _cero   = _no_remesa[1,1]; 

 --if  _cero <> "0" then no funciono

foreach
	select no_documento,
		   monto_bruto,
		   monto_cobrado,
		   monto_comis,
		   comis_cobro,
		   comis_visa,
		   comis_clave,		   
		   no_recibo,
		   secuencia
	  into _no_documento,
		   _monto_bruto_det,
		   _monto_cobrado_det,
		   _monto_comis_det,
		   _comis_cobro,
		   _comis_visa,
		   _comis_clave,		   		   
		   _no_recibo_det,
		   _secuencia		
	  from cobpaex1
	 where numero = a_numero      

	Insert Into cobpaex1 (numero,
			renglon,
			no_remesa,
			secuencia,
			no_documento,
			cliente,
			monto_cobrado,
			fecha_pago,
			neto_pagado,
			no_recibo,
			porc_comis,
			monto_comis,
			comis_desc,
			comis_cobro,
			comis_visa,
			comis_clave,
			monto_bruto,
			error,
			prima_suspenso)
		Values     (_numero,
		_renglon,
		_numero_rem_agt,		
		:ls_secuencia,:ls_poliza,&
					:ls_cliente,:ld_monto_cobrado,:ldt_fecha_pago,:ld_neto_pagado,&
					:ls_no_recibo,:ld_porc_comis,:ld_monto_t_com,:ld_comis_desc,:ld_monto_t_com_cob,&
					:ld_monto_t_com_vis,:ld_monto_t_com_clve,:ld_monto_b_rem, :li_error_poliza, 0);  					
					
					
		Values     (:ls_numero,:li_renglon,:ls_no_rem,:ls_secuencia,:ls_poliza,&
					:ls_cliente,:ld_monto_cobrado,:ldt_fecha_pago,:ld_neto_pagado,&
					:ls_no_recibo,:ld_porc_comis,:ld_monto_t_com,:ld_comis_desc,:ld_monto_t_com_cob,&
					:ld_monto_t_com_vis,:ld_monto_t_com_clve,:ld_monto_b_rem, :li_error_poliza, 0);  

					
end foreach
--else
--	let _messg	= "formato de no_remesa_agt incorrecto.";	
--end if
return 0,_error_desc;
end
end procedure;
