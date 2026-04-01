-- Procedimiento que Realiza la Busqueda de Clientes

-- Creado    : 11/02/2004 - Autor: Amado Perez  

--drop procedure sp_rwf30;

create procedure "informix".sp_rwf30(a_nombre VARCHAR(100) DEFAULT '%') 
RETURNING CHAR(10),
          VARCHAR(100),
          VARCHAR(50),
          CHAR(10),
          VARCHAR(100);
          
--}
DEFINE v_cod_cliente CHAR(10);
DEFINE v_nombre      VARCHAR(100);
DEFINE v_e_mail   	 VARCHAR(50);
DEFINE v_fax         CHAR(10);
DEFINE v_atencion    VARCHAR(100);

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "sp_rwf01.trc"; 
--trace on;

FOREACH WITH HOLD
  SELECT cod_cliente,
         nombre,   
		 e_mail,   
		 fax,
		 atencion   
	INTO v_cod_cliente,
	     v_nombre,
		 v_e_mail,
		 v_fax,
		 v_atencion 
	 FROM recprove  
	WHERE nombre like a_nombre 
 ORDER BY nombre ASC 

IF v_e_mail IS NULL THEN
	LET v_e_mail = "";
END IF

IF v_fax IS NULL THEN
	LET v_fax = "";
END IF

 RETURN v_cod_cliente,
        v_nombre,     
	    v_e_mail,     
	    v_fax,
	    v_atencion   
	    WITH RESUME;
END FOREACH

end procedure;
