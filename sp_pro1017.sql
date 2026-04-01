-- Endoso Beneficio Maximo Vitalicio para Condicion o Diagnostico nombrado

-- Creado    : 25/07/2016 - Autor: Armando Moreno.
DROP PROCEDURE sp_pro1017;
CREATE PROCEDURE "informix".sp_pro1017(a_no_poliza char(10),a_no_endoso char(10))
returning integer;


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
define _observacion		varchar(255);
define _user_added      char(8);
define _error           integer;
define _no_notas        char(10);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro1007.trc";
--trace on;

let _fecha = current;
let _prima_bruta = 0.00;
let _n_agente = "";
let _desc_unidad = "";

SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION


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

select nombre
  into _nombre
  from cliclien
 where cod_cliente = _cod_contratante;

select user_added
  into _user_added
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;
 
 let _fecha_aniversario = mdy(month(_vigencia_inic), day(_vigencia_inic), year(_fecha));

foreach

   select cod_cliente,
          trim(desc_unidad)
     into _cod_aseg,
		  _desc_unidad
	 from endeduni
	where no_poliza = a_no_poliza
	  and no_endoso = a_no_endoso

	select TRIM(nombre)
	  into _nombre_reclamante
	  from cliclien
	 where cod_cliente = _cod_aseg;

   exit foreach;

end foreach


LET _no_notas = sp_sis158("001", 'PRO', '02', 'par_notas');
		 
		 let _observacion = 'A PARTIR DE LA RENOVACION ' || cast(_fecha_aniversario as char(10)) || ' SE INCLUYE ENDOSO PARA CONDICION O DIAGNOSTICO NOMBRADO: ' || trim(_desc_unidad) || ' ASEGURADO ' || trim(_nombre_reclamante);
		 insert into eminotas(
		 no_notas,
		 no_documento,
		 no_poliza,
		 date_added,
		 user_added,
		 descripcion,
		 procesado,
		 user_proceso,
		 date_proceso
	     )	
         values (
         _no_notas,
         _no_documento,
         a_no_poliza,		
         _fecha,       		
		 _user_added,
		 _observacion,
		 1,
		 _user_added,
		 _fecha
		 );

return 0;

END
END PROCEDURE
