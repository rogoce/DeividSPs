-- Procedimiento para generar la informacion de Rechazo de Pagos ACH y TCR
--
-- Creado    : 31/05/2011 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_verif_rechazo_agt;

create procedure "informix".sp_verif_rechazo_agt()
returning char(5), 	 	--_cod_agente,
		  char(50),		--_nom_agt,
		  char(200),	--_email,
		  char(5),
		  char(200),	--_email_cc,
		  char(20),		--_no_documento,
		  integer,		--_mail_secuencia
		  char(10);

define _email				char(200);
define _email_cc			char(200);
define _email_agt			char(50);
define _nom_agente			char(50);
define _dir1				char(30);
define _no_documento		char(20);
define _no_cuenta			char(17);
define _tel_cli				char(10);
define _cod_agente			char(5);
define _no_poliza			char(10);
define _cod_pagador			char(10);
define _user_added			char(8);
define _fecha_exp			char(7);
define _no_lote				char(6);
define _no_tarjeta_parte1	char(5);
define _no_tarjeta_parte2	char(5);
define _cod_banco			char(3);
define _cod_ramo			char(3);
define _tipo_transaccion	smallint;
define _motivo_rechazo		varchar(50);
define _nom_agt				varchar(50);
define _ramo				varchar(50);
define _tipo_tran_char		varchar(30);
define _no_tarjeta			varchar(30);
define _fecha_char			varchar(30);
define _no_cuenta_final		varchar(17);
define _mail_secuencia		integer;
define _len_tarjeta			smallint;
define _len_cuenta			smallint;
define _tipo_tarjeta		smallint;
define _ano					smallint;
define _mes					smallint;
define _dia					smallint;
define _monto				dec(16,2);
define _fecha				date;


set isolation to dirty read;

--SET DEBUG FILE TO "sp_cob275a.trc";
--TRACE ON;

foreach
	select email,
		   secuencia
	  into _email,
		   _mail_secuencia
	  from parmailsend
	 where enviado  = 0
	   and cod_tipo = '00022'

	foreach
		select no_documento,
			   no_remesa
		  into _no_documento,
			   _cod_agente
		  from parmailcomp
		 where mail_secuencia = _mail_secuencia

		call sp_sis21(_no_documento) returning _no_poliza;

		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			 order by porc_partic_agt desc
			exit foreach;
		end foreach

		let _email_cc = ''; 

		foreach
			select email
			  into _email_agt
			  from agtmail
			 where cod_agente = _cod_agente
			   and tipo_correo = 'COB'

			let _email_cc = trim(_email_cc) || trim(_email_agt) || ';';
		end foreach

		select nombre
		  into _nom_agt
		  from agtagent
		 where cod_agente = _cod_agente;

		if trim(_email) = trim(_email_cc) then 
			continue foreach;
		end if

		return _cod_agente,
			   _nom_agt,
			   _email,
			   _cod_agente,
			   _email_cc,
			   _no_documento,
			   _mail_secuencia,
			   _no_poliza with resume;

	end foreach	
end foreach
end procedure
