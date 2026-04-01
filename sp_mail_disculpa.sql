-- procedimiento que genera el html body y la secuencia del envio de correos masivos 	

-- creado    : 15/11/2010 - autor: roman gordon

drop procedure sp_mail_disculpa;

create procedure "informix".sp_mail_disculpa() 
returning	char(10),
			char(50),
			char(10),
			char(10),
			char(10),
			char(10);

define _adjunto			smallint;
define _cantidad		smallint;
define _cnt_parmailsend	smallint;
define _secuencia		integer;
define _error			integer;
define _error_isam		integer;
define _secuencia_comp	integer;
define _html_body		char(512);
define _email		 	char(250);
define _error_desc		char(100);
define _nombre_cli		char(50);
define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_pagador		char(10);
define _tel1			char(10);
define _tel2			char(10);
define _tel3			char(10);
define _celular			char(10);


{on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0;
end exception}


set isolation to dirty read;
--set debug file to "sp_mail_disculpa.trc"; 
--trace on;

foreach
	select distinct doc_remesa
	  into _no_documento
	  from cobredet 
	 where no_recibo like '%HSBC%'
	   and tipo_mov in ('P','N')

	let _no_poliza = sp_sis21(_no_documento);

	select cod_pagador 
	  into _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza;

	let _email	= '';
	let _email 	= sp_sis163(_cod_pagador);
	
	select count(*)
	  into _cnt_parmailsend
	  from parmailsend
	 where cod_tipo = '99999'
	   and email	= _email;

	if _cnt_parmailsend > 0 then
		continue foreach;
	end if

	if _email <> '' then
		let _secuencia	= sp_sis148();
		let _html_body = "<html><img src=cid:informacion.jpg width=850 height=1100>";
			
		Insert into parmailsend(cod_tipo, email, enviado, adjunto, html_body, secuencia)
		Values ('99999', _email, 0, 1, _html_body, _secuencia);

		let _secuencia_comp = sp_sis149();

		insert into parmailcomp (
								secuencia,
								mail_secuencia,
								no_documento,
								renglon,
								no_remesa
								)
					   	  values(
								_secuencia_comp,
								_secuencia,
								_no_documento,
								0,
								''); 
	else
		select nombre,
			   telefono1,
			   telefono2,
			   telefono3,
			   celular
		  into _nombre_cli,
		  	   _tel1,
			   _tel2,
			   _tel3,
			   _celular
		  from cliclien
		 where cod_cliente = _cod_pagador;

		return _cod_pagador,
			   _nombre_cli,
			   _tel1,
			   _tel2,
			   _tel3,
			   _celular with resume;		
	end if			
end foreach

return '',
	   '',
	   '',
	   '',
	   '',
	   '';

end procedure
