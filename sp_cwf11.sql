-- Procedimiento que Realiza la Busqueda de la firma - CONTROL FIRMAS ELECTRONICAS

-- Creado    : 01/10/2009 - Autor: Amado Perez  

drop procedure sp_cwf11;

create procedure "informix".sp_cwf11(a_firma CHAR(20))
 RETURNING VARCHAR(20);
--}
DEFINE _firma          CHAR(20);

--SET DEBUG FILE TO "sp_sis373.trc"; 
--trace on;


set isolation to dirty read;

LET _firma = "";

FOREACH
	select usuario
	  into _firma
	  from insuser
	 where upper(windows_user) = upper(a_firma)

    exit foreach;
END FOREACH
		    

RETURN TRIM(_firma);


end procedure;
