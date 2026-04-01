-- Reporte de Clientes modificados para un dia dado.

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_para_sp_par08_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_par08;

CREATE PROCEDURE sp_par08(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha DATE)
RETURNING CHAR(10),	 -- codigo cliente
		  CHAR(100), -- Nombre
		  CHAR(8),   -- User Added
		  CHAR(8),   -- User Changed
		  DATE,		 -- Date Added
		  DATE,		 -- Date Changed
		  CHAR(30),	 -- Cedula
		  CHAR(50);  -- Compania

DEFINE v_cod_cliente  CHAR(10);  
DEFINE v_nombre		  CHAR(100); 
DEFINE v_nombre_cia   CHAR(50);
DEFINE v_user_added   CHAR(8);
DEFINE v_user_changed CHAR(8);
DEFINE v_cedula 	  CHAR(30);
DEFINE v_date_added, v_date_changed DATE;


SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET  v_nombre_cia = sp_sis01(a_compania); 

{CREATE TEMP TABLE tmp_tabla(
	cuenta		    CHAR(25),
	debito          DEC(16,2),
	credito         DEC(16,2),
	renglon         smallint,
	cheque          CHAR(10),
	anulado         SMALLINT,
	benefi		    CHAR(100),
	seleccionado   	SMALLINT  DEFAULT 1 NOT NULL
	) WITH NO LOG;
CREATE INDEX iend1_tmp_tabla ON tmp_tabla(cuenta);}

FOREACH
		 SELECT	cod_cliente,
		 		nombre,
				user_added,
				user_changed,
				date_added,
				date_changed,
				cedula
				INTO
				v_cod_cliente,
		   		v_nombre,
				v_user_added,
				v_user_changed,
				v_date_added,
				v_date_changed,
				v_cedula
		   FROM	cliclien
		  WHERE date_changed = a_fecha
	   
	RETURN  v_cod_cliente,		 
			v_nombre,
			v_user_added,     
			v_user_changed, 
			v_date_added,
			v_date_changed,
			v_cedula,
			v_nombre_cia
			WITH RESUME;
	
END FOREACH

--DROP TABLE tmp_tabla;

END PROCEDURE;