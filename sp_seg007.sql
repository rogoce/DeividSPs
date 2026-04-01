--- Descripcion: vista de email usuarios cobros
--- Creado: Henry Giron 
--- Fecha:  01/04/2011

drop procedure sp_seg007;

create procedure "informix".sp_seg007(a_compania CHAR(3),a_agencia CHAR(3))
RETURNING CHAR(8),CHAR(50),CHAR(50),CHAR(3),CHAR(100);

DEFINE _usuario			CHAR(8);
DEFINE _codigo_compania	CHAR(3);
DEFINE _codigo_agencia	CHAR(3);
DEFINE _descripcion  	CHAR(50);
DEFINE _email		  	CHAR(50);
DEFINE _nombre          CHAR(100);
  
BEGIN
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_seg007.trc"; 
--TRACE ON;

if a_agencia = "*" then

	FOREACH
		select distinct b.usuario,b.e_mail,c.descripcion,b.codigo_agencia,b.descripcion 
		  into _usuario,_email,_descripcion,_codigo_agencia, _nombre
		  from cobcobra a, segv05:insuser b , segv05:insagen c
		 where a.usuario = b.usuario
		   and b.e_mail is not null
		   and b.status = "A"
		-- and b.codigo_agencia = '010'
		   and b.codigo_compania = "001"
		   and b.codigo_compania = c.codigo_compania
		   and b.codigo_agencia = c.codigo_agencia
		 order by b.descripcion,b.codigo_agencia,b.usuario


		RETURN _usuario,
		       _email,
		       _descripcion,
		       _codigo_agencia,
			   _nombre
			   WITH RESUME;

	END FOREACH

else
	FOREACH
		select distinct b.usuario,b.e_mail,c.descripcion,b.codigo_agencia,b.descripcion 
		  into _usuario,_email,_descripcion,_codigo_agencia, _nombre
		  from cobcobra a, segv05:insuser b , segv05:insagen c
		 where a.usuario = b.usuario
		   and b.e_mail is not null
		   and b.status = "A"
		   and b.codigo_agencia = a_agencia
		   and b.codigo_compania = "001"
		   and b.codigo_compania = c.codigo_compania
		   and b.codigo_agencia = c.codigo_agencia
		 order by b.descripcion,b.codigo_agencia,b.usuario


		RETURN _usuario,				   
		       _email,					   
		       _descripcion,			   
		       _codigo_agencia,			   
			   _nombre					   
			   WITH RESUME;
	END FOREACH
end if

END
end procedure;   
	