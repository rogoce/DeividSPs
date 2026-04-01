
-- Ingreso a parmailsend para ser enviado por correo 00043 PAGO DE RECLAMOS CHEQUE
-- Amado Perez 12/06/2020                                  Asunto: Aseguradora Ancón - Envío de Finiquitos

drop procedure sp_rec310;

create procedure sp_rec310(a_no_tranrec CHAR(10) DEFAULT NULL)
returning integer, char(50);

define ls_e_mail        varchar(255);
define _sender          varchar(100);
define _sender_c        varchar(100);
define _email          	varchar(200);
define _html_body		char(512);
define r_descripcion  	char(50);
define _cod_cliente     char(10);
define _transaccion     char(10);
define _no_requis       char(10);
define _user_tecnico    char(8);
define _cod_chequera	char(3);
define _cod_tipopago    char(3);
define _ramo            char(2);
define r_error_isam   	integer;
define _secuencia2      integer;
define _secuencia       integer;
define _cantidad        integer;
define _contador        integer;
define _adjunto         integer;
define r_error        	integer;
define _cnt             integer;
define _cant_requis     smallint;
define _numrecla        char(20);
define _no_poliza       char(10);
define _cod_ramo        char(3);
define _cod_agente      char(10);
define _cod_tipotran    char(3);
define _no_reclamo      char(10);
define _ramo_sis        smallint;
define _tipo_requis     char(1);
define _user_added      char(8);
define _generar_cheque  smallint;
define _monto           dec(16,2);
define _cod_banco       char(3);

begin

on exception set r_error, r_error_isam, r_descripcion
 	return r_error, r_descripcion;
end exception

set isolation to dirty read;

let r_error       = 0;
let r_descripcion = 'Actualizacion Exitosa ...';
let	_cnt          = 0;
let _generar_cheque = 0;
let _monto = 0.00;
let _cod_banco = '';
let _cod_chequera = '';

--set debug file to "sp_rec310.trc"; 
--trace on;

let _sender = "";
let _sender_c = "";

--let _sender = 'aperez@asegurancon.com';
let _no_requis = null;

	select cod_cliente,
           cod_tipotran,
           cod_tipopago,
           no_reclamo,
           no_requis,
           user_added,
           generar_cheque,
           monto		   
	  into _cod_cliente,
           _cod_tipotran,
           _cod_tipopago,
           _no_reclamo,
           _no_requis,
           _user_added,
           _generar_cheque,
           _monto		   
	  from rectrmae
	 where no_tranrec = a_no_tranrec;
	 	 
	if _cod_tipotran <> '004' then
		return 0, "No es transacccion de pago";
	end if
	
	if _generar_cheque = 0 then
		return 0, "No genera cheque";
	end if

	if _no_requis is null or trim(_no_requis) = "" then
		return 0, "Requisicion en nulo";
	end if
	
	if _monto <= 0 then
		return 0, "Monto menor o igual cero";
	end if	
	
	select tipo_requis,
	       cod_banco,
		   cod_chequera
	  into _tipo_requis,
	       _cod_banco,
		   _cod_chequera
	  from chqchmae
	 where no_requis = _no_requis;
	 
	if _tipo_requis <> 'A' then
		return 0, "Requis no es ACH";
	end  if

    if _cod_banco = '295' then
		return 0, "Cliente es Banisi";	
	end if
 	
	-- Copia para el ajustador
	
	select e_mail
	  into _sender
	  from insuser
	 where usuario = _user_added;
	 
	if _sender is null then
		let _sender = "";
	end if	

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo =_no_reclamo;
	 
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;
	
    -- Queda pendiente patrimoniales y fianzas	
	if _ramo_sis = 1 then 	-- Automovil
		if _cod_tipopago <> '003' then
			return 0, "No es pago a asegurado";
		end if
		
		-- Buscando si tien los concepto son 015 PAGO DIRECTO ASEG. o 044 REEMBOLSO AL ASEGURADO
		select count(*)
		  into _cnt
		  from rectrcon a
		 where a.no_tranrec = a_no_tranrec
		   and a.cod_concepto in ('015','044');
		   
		if _cnt is null then
			let _cnt = 0;
		end if
		
		if _cnt = 0 then
			return 0, "No tiene concepto pago a asegurado";
		end if
	elif _ramo_sis in (5, 7) then -- Personas
		if _cod_tipopago <> '004' then
			return 0, "No es pago a tercero";
		end if
		return 0, "Aun no se implementa";
	else
	    return 0, "Este ramo no genera finiquito";
	end if
	 --  and no_requis = '710187'

	let _adjunto = 1;

 	let ls_e_mail = "";

	select e_mail
	  into ls_e_mail
	  from cliclien 
	 where cod_cliente = _cod_cliente;

	if ls_e_mail is null then
		let ls_e_mail = "";
	end if 

	select count(*)
	  into _cantidad 
	  from climail 
	 where cod_cliente = _cod_cliente;

	if _cantidad > 0 then
		foreach
			select email 
			  into _email 
			  from climail 
			 where cod_cliente = _cod_cliente

			let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email);
		end foreach
	end if

 	let _email = "";
	
	if trim(_email) <> "" then
		let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email);
	end if

	if ls_e_mail is not null and trim(ls_e_mail) <> "" then
		select count(*)
		  into _cant_requis
		  from parmailcomp
		 where no_remesa = a_no_tranrec;
		 
		if _cant_requis = 0 then
		--	For _contador = 1 to _adjunto
			let _secuencia = sp_par336('00043', ls_e_mail, 1);-- Amado - se cambia para que solo envie la primera imagen - 18/06/2013
			
			update parmailsend 
			   set sender   	= _sender
			 where secuencia	= _secuencia;

				
		--	end for

			select max(secuencia)
			  into _secuencia2
			  from parmailcomp;

			if _secuencia2 is null then
				let _secuencia2 = 0;
			end if

			let _secuencia2 = _secuencia2 + 1;

			insert into parmailcomp(
					secuencia,
					no_remesa,
					renglon,
					mail_secuencia)
			values(	_secuencia2,
					a_no_tranrec,
					0,
					_secuencia);
		end if
	end if
--END FOREACH

return r_error, r_descripcion;

end
end procedure;