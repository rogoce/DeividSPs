-- Detalle de Pago para los Proveedores
-- Proyecto Unificacion de los Cheques de Salud

-- Creado: 29/08/2025 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_prud01_gen;

create procedure "informix".sp_prud01_gen()
returning varchar(30) 	as _id,
          varchar(40) 	as aseg_primer_ape,
          varchar(80)	as aseg_nombres,
          varchar(40)  	as aseg_primer_ape1,
          smallint 		as relacion,
          smallint 		as genero,
          date      	as fecha_aniversario,
          varchar(30)  	as di,
          date      	as fecha_inicio,
          date			as vigencia_final,
          varchar(50)	as nombre,
          varchar(50)  	as e_mail,
          varchar(10)  	as celular,
          smallint  	as operacion,
          varchar(10)  	as cod_cliente,
		  varchar(20)  	as no_documento,
		  smallint  	as const;


define v_id				 char(30);	
define v_aseg_primer_ape   char(40);
define v_aseg_nombres      char(80);
define v_aseg_primer_ape1  char(40);
define v_relacion          smallint;
define v_genero            smallint;
define v_fecha_aniversario date;
define v_di                char(30);
define v_fecha_inicio      date;
define v_vigencia_final    date;
define v_nombre            char(50);
define v_e_mail            char(50);
define v_celular           char(10);
define v_operacion         smallint;
define v_cod_cliente       char(10);
define v_no_documento      char(20);
define v_const             smallint;


set isolation to dirty read;

    -- Recorremos fila por fila el UNION con FOREACH
    FOREACH
        SELECT *
        INTO v_id, v_aseg_primer_ape, v_aseg_nombres, v_aseg_primer_ape1,
             v_relacion, v_genero, v_fecha_aniversario, v_di, v_fecha_inicio,
             v_vigencia_final, v_nombre, v_e_mail, v_celular, v_operacion,
             v_cod_cliente, v_no_documento, v_const
        FROM (
            -- Primer SELECT
            SELECT replace(ase.cedula,'-','') AS v_id,
                   ase.aseg_primer_ape AS v_aseg_primer_ape,
                   trim(nvl(ase.aseg_primer_nom,'')) || ' ' || trim(nvl(ase.aseg_segundo_nom,'')) AS v_aseg_nombres,
                   trim(nvl(ase.aseg_primer_ape,'')) AS v_aseg_primer_ape1,
                   '-1' AS v_relacion,
                   decode(ase.sexo,'F',0,'M',1) AS v_genero,
                   ase.fecha_aniversario AS v_fecha_aniversario,
                   trim(replace(ase.cedula,'-','')) AS v_di,
                   min(uni.vigencia_inic) AS v_fecha_inicio,
                   max(uni.vigencia_final) AS v_vigencia_final,
                   ram.nombre AS v_nombre,
                   ase.e_mail AS v_e_mail,
                   trim(replace(ase.celular,'-','')) AS v_celular,
                   1 AS v_operacion,
                   ase.cod_cliente AS v_cod_cliente,
                   emi.no_documento AS v_no_documento,
                   1 AS v_const
            FROM emipomae emi
            INNER JOIN emipouni uni ON uni.no_poliza = emi.no_poliza AND uni.activo = 1
            INNER JOIN cliclien ase ON ase.cod_cliente = uni.cod_asegurado
            INNER JOIN prdramo ram ON ram.cod_ramo = emi.cod_ramo and cod_area in (0,1)
            INNER JOIN emipoliza pol ON pol.no_documento = emi.no_documento
            WHERE emi.actualizado = 1
              AND emi.estatus_poliza = 1
              AND ase.tipo_persona = 'N'
			  and emi.cod_tipoprod != '002'
			  and pol.fecha_suspension > today
            GROUP BY 1,2,3,4,5,6,7,8,11,12,13,ase.cod_cliente,emi.no_documento

        ) AS union_result
        ORDER BY v_fecha_aniversario

        -- Retornamos cada fila al cliente
        RETURN trim(v_id), 
			   trim(v_aseg_primer_ape),
			   trim(v_aseg_nombres), 
			   trim(v_aseg_primer_ape1),
               v_relacion, 
			   v_genero, 
			   v_fecha_aniversario, 
			   trim(v_di), 
			   v_fecha_inicio,
               v_vigencia_final, 
			   trim(v_nombre), 
			   trim(v_e_mail), 
			   trim(v_celular), 
			   v_operacion ,
               trim(v_cod_cliente), 
			   trim(v_no_documento), 
			   v_const
        WITH RESUME;
	END FOREACH;
END PROCEDURE;
