--Procedimiento que devuelve el vendedor
--Armando Moreno M.
--23/10/2025

DROP PROCEDURE sp_sis525;
CREATE PROCEDURE sp_sis525(a_cod_agente CHAR(5), a_cod_sucursal char(3) default '001',a_cod_ramo char(3))
 RETURNING varchar(50),char(3),varchar(50);

DEFINE _cod_vendedor		CHAR(3);
DEFINE _n_vendedor			varchar(50);
DEFINE _n_corredor  		varchar(50);

SET ISOLATION TO DIRTY READ;


select cod_vendedor
  into _cod_vendedor
  from parpromo
 where cod_agente  = a_cod_agente
   and cod_agencia = a_cod_sucursal
   and cod_ramo    = a_cod_ramo;
   
select nombre
  into _n_vendedor
  from agtvende
 where cod_vendedor = _cod_vendedor;

select nombre
  into _n_corredor
  from agtagent
 where cod_agente = a_cod_agente;  

  
RETURN _n_corredor,_cod_vendedor,_n_vendedor;

END PROCEDURE;