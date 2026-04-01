
-- Ingreso a parmailsend para ser enviado por correo 00035 Acumula a Deducible de Reclamo y 00036 Declinación de Reclamo de Salud
-- Amado Perez 02/11/2017                            00035 Asunto: Aseguradora Ancón - Acumula a Deducible y 00036 Aseguradora Ancón - Declinación del Reclamo
-- Deivid Gestion

drop procedure sp_rec740;

create procedure sp_rec740()
returning smallint, char(30);

define ls_e_mail        varchar(255);
define _sender          varchar(100);
define _sender_c        varchar(100);
define _email          	varchar(200);
define _email_agt       varchar(50);
define _html_body		char(512);
define r_descripcion  	char(30);
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
define _no_tranrec      char(10);
define _no_reclamo      char(10);
define _a_deducible     dec(16,2);
define _monto           dec(16,2);
define _cod_asegurado   char(10);

begin

on exception set r_error, r_error_isam, r_descripcion
 	return r_error, r_descripcion;
end exception

set isolation to dirty read;

let r_error       = 0;
let r_descripcion = 'Actualizacion Exitosa ...';
let	_cnt          = 0;

--set debug file to "sp_che155.trc"; 
--trace on;

let _sender = "";
let _sender_c = "";

foreach
	select email
	  into _sender_c
	  from parcocue
	 where cod_correo = '096' --> Acumula Deducible y Declinación de Reclamos (envio masivo cc)
	   and activo = 1

	if trim(_sender_c) <> "" and _sender_c is not null then
		let _sender = _sender || trim(_sender_c) || ";"; 
	end if
end foreach
  let _sender = trim(_sender) || 'jeperez@asegurancon.com;';
--let _sender = 'cvillamonte@asegurancon.com;kcesar@asegurancon.com;';

-- Acumula a Deducible
foreach                         
	select no_tranrec,
	       no_reclamo,
           transaccion,
           cod_cliente		   
	  into _no_tranrec,
	       _no_reclamo,
		   _transaccion,
		   _cod_cliente
	  from rectrmae
	 where numrecla[1,2] = '18'
	   and cod_tipotran = '004'
	   and cod_tipopago = '003'
	   and actualizado = 1
	   and anular_nt is null
	   and fecha = today - 1
	   
	select sum(a_deducible),
           sum(monto)
      into _a_deducible,
           _monto
      from rectrcob
     where no_tranrec = _no_tranrec;

    if _a_deducible > 0 and _monto = 0 then	 

		let _adjunto = 1;

		let ls_e_mail = "";

		select e_mail
		  into ls_e_mail
		  from cliclien 
		 where cod_cliente = _cod_cliente;

		if ls_e_mail is null then
			let ls_e_mail = "";
		end if 

{		select count(*)
		  into _cantidad 
		  from climail 
		 where cod_cliente = _cod_cliente;

		if _cantidad > 0 then
			foreach
				select email 
				  into _email 
				  from climail 
				 where cod_cliente = _cod_cliente

				if trim(_email) <> "" and _email is not null then
					let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email);
				end if
			end foreach
		end if
}
		let _email = "";
		
		if ls_e_mail is not null and trim(ls_e_mail) <> "" then
		
		-- Enviando copia a Agente			 
			select no_poliza
			  into _no_poliza
			  from recrcmae
			 where no_reclamo = _no_reclamo;
						 
			foreach
				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = _no_poliza
				
				if _cod_agente = '00035' then
					let _email_agt = 'saludindividual@unityducruet.com';
				else
				    select email_reclamo
					  into _email_agt
					  from agtagent
					 where cod_agente = _cod_agente;
				end if
				
				if trim(_email_agt) <> "" and _email_agt is not null then
					let _sender = trim(_sender) || trim(_email_agt) || ";"; 				
	--				let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email_agt);
				end if
			end foreach      		 
		
			--if trim(_email) <> "" and _email_agt is not null then
			--	let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email);
			--end if
		
			select count(*)
			  into _cant_requis
			  from parmailcomp
			 where no_remesa = _no_tranrec;
			 
			if _cant_requis = 0 then
			--	For _contador = 1 to _adjunto
				let _secuencia = sp_par336('00035', ls_e_mail, 1);-- Amado - se cambia para que solo envie la primera imagen - 18/06/2013
				
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
						_no_tranrec,
						0,
						_secuencia);
			end if
		end if
	end if
END FOREACH

-- Declinación del Reclamo
foreach
	select no_tranrec,
	       no_reclamo,
           transaccion,
           cod_cliente		   
	  into _no_tranrec,
	       _no_reclamo,
		   _transaccion,
		   _cod_cliente
	  from rectrmae
	 where numrecla[1,2] = '18'
	   and cod_tipotran = '013'
	   and actualizado = 1
	   and anular_nt is null
	   and fecha = today - 1

	select cod_asegurado,
	       no_poliza
	  into _cod_asegurado,
	       _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	   
		let _adjunto = 1;

		let ls_e_mail = "";

	if _cod_asegurado <> _cod_cliente then -- Es proveedor
		select e_mail
		  into ls_e_mail
		  from cliclien 
		 where cod_cliente = _cod_cliente;

		if ls_e_mail is null then
			let ls_e_mail = "";
		end if 
		
		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			
			if _cod_agente = '00035' then
				let _email_agt = 'saludindividual@unityducruet.com';
			else
				select email_reclamo
				  into _email_agt
				  from agtagent
				 where cod_agente = _cod_agente;
			end if
			
			if trim(_email_agt) <> "" and _email_agt is not null then
				if trim(_email_agt) = trim(ls_e_mail) then
					let ls_e_mail = "";
				end if
			end if
		end foreach      		 
	
	else -- Asegurado

		select e_mail
		  into ls_e_mail
		  from cliclien 
		 where cod_cliente = _cod_cliente;

		if ls_e_mail is null then
			let ls_e_mail = "";
		end if 

{		select count(*)
		  into _cantidad 
		  from climail 
		 where cod_cliente = _cod_cliente;

		if _cantidad > 0 then
			foreach
				select email 
				  into _email 
				  from climail 
				 where cod_cliente = _cod_cliente

				if trim(_email) <> "" and _email is not null then
					let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email);
				end if
			end foreach
		end if
}
		let _email = "";
		if ls_e_mail is not null and trim(ls_e_mail) <> "" then
		
		-- Enviando copia a Agente			 
			select no_poliza
			  into _no_poliza
			  from recrcmae
			 where no_reclamo = _no_reclamo;
						 
			foreach
				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = _no_poliza
				
				if _cod_agente = '00035' then
					let _email_agt = 'saludindividual@unityducruet.com';
				else
				    select email_reclamo
					  into _email_agt
					  from agtagent
					 where cod_agente = _cod_agente;
				end if
				
				if trim(_email_agt) <> "" and _email_agt is not null then
					let _sender = trim(_sender) || trim(_email_agt) || ";"; 				
				--	let _email = _email || ";" || trim(_email_agt);
				end if
			end foreach      		 
		
		--	if trim(_email) <> "" and _email_agt is not null then
		--		let ls_e_mail = trim(ls_e_mail) || ";" || trim(_email);
		--	end if
		End IF
	End If	
		
	if ls_e_mail is not null and trim(ls_e_mail) <> "" then
		select count(*)
		  into _cant_requis
		  from parmailcomp
		 where no_remesa = _no_tranrec;
		 
		if _cant_requis = 0 then
		--	For _contador = 1 to _adjunto
			let _secuencia = sp_par336('00036', ls_e_mail, 1);-- Amado - se cambia para que solo envie la primera imagen - 18/06/2013

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
					_no_tranrec,
					0,
					_secuencia);
		end if
	end if
END FOREACH

return r_error, r_descripcion  with resume;

end
end procedure;