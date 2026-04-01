-- Endoso Beneficio Maximo Vitalicio para Condicion o Diagnostico nombrado

-- Creado    : 25/07/2016 - Autor: Armando Moreno.
DROP PROCEDURE sp_pro1016;
CREATE PROCEDURE "informix".sp_pro1016(a_no_poliza char(10),a_no_endoso char(10))
returning varchar(100),date,char(20),char(100),char(100),varchar(100),date,char(50),char(50),char(100);


define _nombre			varchar(100);
define _cod_contratante char(10);
define _cod_aseg        char(10);
define _no_documento    char(20);
define _vigencia_inic   date;
define _fecha_actual    char(100);
define _fecha           date;
define _vigencia_inic_c,_fecha_emision_c char(100);
define _nombre_reclamante     varchar(100);
define _prima_bruta     decimal(16,2);
define _cod_agente      char(5);
define _n_agente        char(50);
define _desc_unidad     char(50);
define _fecha_emision   date;
define _fecha_aniversario date;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro1007.trc";
--trace on;

let _fecha = current;
let _prima_bruta = 0.00;
let _n_agente = "";
let _desc_unidad = "";

BEGIN

select no_documento,
       vigencia_inic,
	   cod_contratante,
	   prima_bruta
  into _no_documento,
	   _vigencia_inic,
	   _cod_contratante,
	   _prima_bruta
  from emipomae
 where no_poliza = a_no_poliza;

select fecha_emision
  into _fecha_emision
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

foreach
	select cod_agente
	  into _cod_agente
	  from emipoagt
	 where no_poliza = a_no_poliza

	exit foreach;
end foreach   

select nombre
  into _nombre
  from cliclien
 where cod_cliente = _cod_contratante;


 
 let _fecha_aniversario = mdy(month(_vigencia_inic), day(_vigencia_inic), year(_fecha));

 foreach

   select cod_cliente,
          trim(desc_unidad)
     into _cod_aseg,
		  _desc_unidad
	 from endeduni
	where no_poliza = a_no_poliza
	  and no_endoso = a_no_endoso

	select nombre
	  into _nombre_reclamante
	  from cliclien
	 where cod_cliente = _cod_aseg;

   exit foreach;

end foreach

call sp_sis20(_fecha) returning _fecha_actual;
call sp_sis20(_vigencia_inic) returning _vigencia_inic_c;
call sp_sis20(_fecha_aniversario) returning _fecha_emision_c;

select nombre into _n_agente from agtagent where cod_agente = _cod_agente;

return _nombre,
	   _vigencia_inic,
	   _no_documento,
	   _fecha_actual,
	   _vigencia_inic_c,
	   _nombre_reclamante,
	   _fecha_aniversario,
	   _n_agente,
	   _desc_unidad,
	   _fecha_emision_c;

END
END PROCEDURE
