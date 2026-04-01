-- Procedure que actualiza estado de impresion de aviso de cancelación.  
-- procedure que actualiza estado de impresion de 
-- Creado    : 26/2/2016 - Autor: Henry Girón.  
-- SIS v.2.0 - DEIVID, S.A.  
-- Set debug file to 'sp_log010.trc';  
-- trace on ;  

Drop procedure sp_log010; 
CREATE procedure "informix".sp_log010(a_no_aviso char(10)) 
   RETURNING CHAR(20),  -- poliza  
             char(100), -- cliente  
			 char(50),  -- corredor  
			 char(50),  -- acreedor 
			 date,      -- fecha_aviso 
			 date,      -- date_imp_aviso_log 
             char(15),	-- user_imp_aviso_log 
			 char(10);  -- no_aviso   

BEGIN 

    define _no_documento       char(20);  
    define _name_corredor  	   char(50); 
    define _name_cliente       char(100); 
	define _name_acreedor	   char(50); 
	define _fecha_aviso        date; 
    define _user_imp_aviso_log char(15); 
    define _date_imp_aviso_log date; 
	define _no_poliza          char(10); 

	SET ISOLATION TO DIRTY READ; 
	
	
	
	select n.nombre nombre,a.no_poliza poliza
  from  emipoacr e, emiacre n, avisocanc a
where a.no_aviso = (a_no_aviso)
       and ( a.estatus in ('I')  and a.cancela = "0" )
       and ( trim(a.cod_acreedor) <> "" )
	   --and a.saldo > 0
       and a.imp_aviso_log = '3' -- Correccion ya que salian incluso sin haber sido impreso 4/8/16 Henry
       and e.cod_acreedor = n.cod_acreedor
     and e.no_poliza = a.no_poliza
group by n.nombre,a.no_poliza
into temp acreedor_tmp; 			

    insert into acreedor_tmp(nombre,poliza)
	select distinct a.nombre_acreedor nombre,a.no_poliza poliza
	  from avisocanc a, emipomae b
	 where a.no_aviso IN (SELECT codigo FROM tmp_codigos ) 
       and ( a.estatus in ('I')  and a.cancela = "0" )
       and ( trim(a.cod_acreedor) <> "" )
	   --and a.saldo > 0
       and a.imp_aviso_log = '3'
	   and a.no_poliza = b.no_poliza
	   and b.leasing = 1;

FOREACH 
	select a.no_documento, 
	       a.nombre_cliente, 
           a.nombre_agente, 
           t.nombre, --a.nombre_acreedor, 
           a.fecha_proceso, 
           a.date_imp_aviso_log, 
		   a.user_imp_aviso_log, a.no_poliza 
	  into _no_documento, 
           _name_cliente, 
           _name_corredor, 
		   _name_acreedor, 
		   _fecha_aviso, 
		   _date_imp_aviso_log, 
           _user_imp_aviso_log, _no_poliza 
	  from avisocanc a, acreedor_tmp t
	 where a.no_aviso = (a_no_aviso)	 
	   and ( a.estatus in ('I')  and a.cancela = "0" )
       and ( trim(a.cod_acreedor) <> "" ) 
	   --and a.saldo > 0	
	   and a.imp_aviso_log = '3' -- Correccion ya que salian incluso sin haber sido impreso 4/8/16 Henry
	   and a.no_poliza = t.poliza
     order by t.nombre,a.no_aviso,a.nombre_cliente 	   
--	   order by a.nombre_acreedor,a.nombre_cliente 

	   {	FOREACH 
		select distinct n.nombre
		  into _name_acreedor
		  from  emipoacr e, emiacre n
		 where e.cod_acreedor = n.cod_acreedor
		   and e.no_poliza = _no_poliza	 }
		   
		  RETURN _no_documento, 
				 _name_cliente, 
				 _name_corredor, 
				 _name_acreedor, 
				 _fecha_aviso, 
				 _date_imp_aviso_log, 
				 _user_imp_aviso_log, 
				 a_no_aviso 
				 WITH RESUME; 
				 
		--end foreach

end foreach
drop table acreedor_tmp;
END

END PROCEDURE;
