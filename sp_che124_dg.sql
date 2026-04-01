-- Ingreso a parmailsend para ser enviado por correo
-- Amado Perez 29/03/2011
-- Henry Giron 10/07/2020 F9:35040

drop procedure sp_che124;

create procedure sp_che124(a_no_cheque integer)
returning smallint, char(30);

define ls_e_mail        varchar(200);
define _sender          varchar(100);
define _sender_reclamo  varchar(100);
define _sender_act      varchar(100);
define _sender_c        varchar(100);
define _email          	varchar(50);
define _html_body		char(512);
define r_descripcion  	char(30);
define _cod_cliente     char(10);
define _transaccion     char(10);
define _no_requis       char(10);
define _user_tecnico    char(8);
define _cod_agente      char(5);
define _cod_chequera	char(3);
define _cod_tipopago    char(3);
define _ramo            char(2);
define _origen_cheque   char(1);
define _secuencia_ctrl  integer;
define r_error_isam   	integer;
define _secuencia2      integer;
define _secuencia       integer;
define _cantidad        integer;
define _contador        integer;
define _adjunto         integer;
define r_error        	integer;
define _cnt             integer;


begin

on exception set r_error, r_error_isam, r_descripcion
 	return r_error, r_descripcion;
end exception

set isolation to dirty read;

let r_error       = 0;
let r_descripcion = 'Actualizacion Exitosa ...';
let	_cnt          = 0;

let _sender_act     = '';
let _sender_reclamo = '';
let _secuencia_ctrl = 0;


--set debug file to "sp_che124.trc"; 
--trace on;

let _sender = "";
let _sender_c = "";

foreach
	select email
	  into _sender_c
	  from parcocue
	 where cod_correo = '062' --> ach pago de reclamos (envio masivo cc)
	   and activo = 1

	if trim(_sender_c) <> "" and _sender_c is not null then
		let _sender = _sender || trim(_sender_c) || ";"; 
	end if
end foreach

 select cod_agente
   into _cod_agente
   from emipoagt  a, emipomae b
  where a.no_poliza = b.no_poliza
    and b.no_documento = '1819-99900-01';


Select Trim(email_reclamo)
  into _sender_reclamo
  from agtagent
 where cod_agente = _cod_agente; -- f9:35040  CC = 'mensajeria@urenayurena.net' --  
 
if trim(_sender_reclamo) <> "" and _sender_reclamo is not null then
	let _sender_reclamo =  trim(_sender_reclamo) ; 
else
	let _sender_reclamo = "";
end if	

foreach
	select no_requis,
		   cod_cliente,
           origen_cheque		   
	  into _no_requis,
		   _cod_cliente,
		   _origen_cheque
	  from chqchmae
	 where no_cheque = a_no_cheque
	   and tipo_requis = 'A'
--	   and no_requis = '525086'

	let _adjunto = 0;

    foreach
		select numrecla[1,2],transaccion
		  into _ramo,_transaccion
		  from chqchrec
		 where no_requis = _no_requis

        exit foreach;
    end foreach
	


    if _ramo in ('18','04') then
		let _adjunto = 2;
		
	  select cod_tipopago
		into _cod_tipopago
		from rectrmae
		where transaccion = _transaccion;	
	else
	    let _transaccion = null;
		
		call sp_che114(_no_requis) returning _transaccion, _cod_tipopago;
		
		if _transaccion is null or trim(_transaccion) = "" then
		else
			let _adjunto = 1;

			select count(*)
			  into _cantidad
			  from chqchrec
			 where no_requis = _no_requis;

			if _cantidad > 1 then
				let _adjunto = 2;
			end if 
		end if
	end if

	let ls_e_mail = "";

	select e_mail
	  into ls_e_mail
	  from cliclien 
	 where cod_cliente = _cod_cliente;

	if ls_e_mail is null then
		let ls_e_mail = "";
	end if 
	
	if _cod_tipopago in ('001') then	
		if ls_e_mail = _sender_reclamo then
			continue foreach;
		end if
	end if	
	
	if _cod_tipopago not in ('003','001') then

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

				if _email is null then
					let _email = '';
				end if

				if _email = '' then
					continue foreach;
				end if

				let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email);
			end foreach
		end if

		if ls_e_mail = '' then
			continue foreach;
		end if
	end if	

	
    For _contador = 1 to _adjunto
		let _secuencia = sp_par336('00016', ls_e_mail, 1);-- Amado - se cambia para que solo envie la primera imagen - 18/06/2013

		if _cod_tipopago = '003' then	
			let _sender_act = _sender || trim(_sender_reclamo) || ";"; 		
		else
			let _sender_act = _sender ; 
		end if
		
		let _secuencia_ctrl = _secuencia;
		
		update parmailsend 
		   set sender   	= _sender_act   --_sender
		 where secuencia	= _secuencia;
	end for
		

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
			_no_requis,
			0,
			_secuencia);
END FOREACH

return r_error, r_descripcion  with resume;

end
end procedure;