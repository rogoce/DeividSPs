-- Creado    : 14/10/2015 - Autor: Armando Moreno
--

DROP PROCEDURE sp_bono05;

CREATE PROCEDURE sp_bono05(a_cod_agente CHAR(5), a_porc_bono decimal(16,2), a_periodo char(7)) 
RETURNING integer;
		  
DEFINE _cod_agente       CHAR(5);
DEFINE _prima_suscrita   DECIMAL(16,2);
DEFINE _prima_cobrada    DECIMAL(16,2);
DEFINE _porc_bono        DECIMAL(16,2);
DEFINE _prima_bono       DECIMAL(16,2);
DEFINE _return           smallint;
DEFINE _n_corredor       CHAR(50);
DEFINE _cod_cliente      CHAR(10);
DEFINE _n_cte			 char(50);
DEFINE _no_poliza        char(10);
DEFINE _no_documento     char(20);


--let _return = sp_bono01();
select nombre
  into _n_corredor
  from agtagent
 where cod_agente = a_cod_agente;
 
foreach
	select prima_cobrada,
		   prima_suscrita,
		   no_poliza,
		   no_documento
	  into _prima_cobrada,
		   _prima_suscrita,
		   _no_poliza,
		   _no_documento
	  from bono_prod_d
	 where cod_agente_uni = a_cod_agente
	 
	 select cod_contratante
	   into _cod_cliente
	   from emipomae
	  where no_poliza = _no_poliza;

	 select nombre
	   into _n_cte
	   from cliclien
	  where cod_cliente = _cod_cliente;
	
	 
	insert into chqborege(
			cod_agente,
			no_poliza,
			prima_suscrita,
			comision,
			nombre,
			no_documento,
			seleccionado,
			periodo,
			fecha_genera,
			no_requis,
			tipo_requis,
			nombre_cte,
			porcentaje,
			prima_cobrada)
	values(	a_cod_agente,
			_no_poliza,
			_prima_suscrita,
			_prima_cobrada * a_porc_bono /100,
			_n_corredor,
			_no_documento,
			0,
			a_periodo,
			CURRENT, 
			'',
			'',
			_n_cte,
			a_porc_bono,
			_prima_cobrada
			);
end foreach
return 0;
END PROCEDURE;