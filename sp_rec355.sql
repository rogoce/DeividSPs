
-- Ingreso a parmailsend para ser enviado por correo 00043 PAGO DE RECLAMOS CHEQUE
-- Amado Perez 12/06/2020                                  Asunto: Aseguradora Ancón - Envío de Finiquitos

drop procedure sp_rec355;

create procedure sp_rec355(a_no_tranrec CHAR(10) DEFAULT NULL)
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
	
	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo =_no_reclamo;
	 
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 

	let _adjunto = 1;

 	let ls_e_mail = "";
	
	select count(*)
	  into _cnt
	  from emipoagt a, agtagent b
	 where a.cod_agente = b.cod_agente
	   and a.no_poliza = _no_poliza;
	
	if _cnt is null then
		let _cnt = 0;
	end if	   

	if _cnt > 0 then
		select e_mail
		  into ls_e_mail
		  from cliclien 
		 where cod_cliente = _cod_cliente;
	end if

	if ls_e_mail is null then
		let ls_e_mail = "";
	end if 
	
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		
        select e_mail
          into _email
          from agtagent
         where cod_agente = _cod_agente;

		if _email is null then
			let _email = "";
		end if 
        		 
		if trim(_email) <> "" then
			let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email);
		else
			let ls_e_mail = trim(_email);
		end if
	end foreach	 

	if ls_e_mail is not null and trim(ls_e_mail) <> "" then
		select count(*)
		  into _cant_requis
		  from parmailcomp
		 where no_remesa = a_no_tranrec;
		 
		if _cant_requis = 0 then
		--	For _contador = 1 to _adjunto
			let _secuencia = sp_par336('00056', ls_e_mail, 1);-- Amado - se cambia para que solo envie la primera imagen - 18/06/2013
			
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