

DROP PROCEDURE sp_sis518;
CREATE PROCEDURE sp_sis518(a_cod_cliente CHAR(10))
RETURNING smallint,char(20);

DEFINE _cnt		smallint;
define _no_documento char(20);

SET ISOLATION TO DIRTY READ;

select count(*)
  into _cnt
  from emipomae e, emipouni u
 where e.no_poliza = u.no_poliza
 and e.actualizado = 1
   and e.cod_ramo = '019'
   and e.estatus_poliza = 1
   and u.cod_asegurado = a_cod_cliente;
   
if _cnt is null then
	let _cnt = 0;
end if
let _no_documento = '';
if _cnt > 0 then
	foreach
		select e.no_documento
		  into _no_documento
		  from emipomae e, emipouni u
		 where e.no_poliza = u.no_poliza
		   and e.actualizado = 1
	       and e.cod_ramo = '019'
		   and e.estatus_poliza = 1
		   and u.cod_asegurado = a_cod_cliente
		   
		   let _no_documento = trim(_no_documento);
		   
		   exit foreach;
	end foreach
end if
return _cnt,_no_documento;   

END PROCEDURE 
                                                                                                                                                                                   