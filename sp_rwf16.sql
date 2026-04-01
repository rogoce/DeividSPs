-- Consulta de Partes

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf16;

CREATE PROCEDURE sp_rwf16(a_tamano CHAR(1) default "%")
RETURNING char(5),
      	  char(50),
		  char(20),
		  char(15),
		  varchar(90),
          dec(16,2),
          smallint;

define v_no_parte		char(5);
define v_desc_parte		char(50);
define _loc_pieza		char(2);
define _se_repara		smallint;
define _se_cambia		smallint;
define _se_pinta		smallint;
define _se_pintarep		smallint;
define v_localizacion	char(20);
define _trabajo			char(1);
define v_precio_chico	dec(16,2);
define v_precio_mediano	dec(16,2);
define v_precio_grande	dec(16,2);
define v_trabajo		char(15);
define _precio_char     char(16);
define v_concat         varchar(90);
define v_bloqueado		smallint;

--set debug file to "sp_rwf02.trc";


SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	no_parte,
        desc_parte,
		loc_pieza,
		se_repara,
		se_cambia,
		se_pinta,
		se_pintarep,
		bloqueado
   INTO v_no_parte,
        v_desc_parte,
		_loc_pieza,
		_se_repara,
		_se_cambia,
		_se_pinta,
		_se_pintarep,
		v_bloqueado
   FROM	recparte 
  WHERE activo = 1
  ORDER BY 2

  If _loc_pieza = '01' Then
    let v_localizacion = 'Frontal';
  Elif _loc_pieza = '02' Then
    let v_localizacion = 'Trasera';
  Elif _loc_pieza = '03' Then
    let v_localizacion = 'Capota';
  Elif _loc_pieza = '04' Then
    let v_localizacion = 'Lateral Derecho';
  Elif _loc_pieza = '05' Then
    let v_localizacion = 'Lateral Izquierdo';
  Elif _loc_pieza = '06' Then
    let v_localizacion = 'Parabrisas';
  Elif _loc_pieza = '07' Then
    let v_localizacion = 'Interior del Auto';
  Elif _loc_pieza = '08' Then
    let v_localizacion = 'Debajo del Auto';
  Elif _loc_pieza = '09' Then
    let v_localizacion = 'Motor';
  End If

  FOREACH
	  SELECT trabajo,
	         precio_chico,
			 precio_mediano,
			 precio_grande
		INTO _trabajo,
			 v_precio_chico,
			 v_precio_mediano,
		  	 v_precio_grande
		FROM recprec
	   WHERE no_parte = v_no_parte

	  let _trabajo = trim(_trabajo);

	  if _trabajo = '1' Then
	     let v_trabajo = 'Reparar';
	  elif _trabajo = '2' Then
	     let v_trabajo = 'Cambiar';
	  elif _trabajo = '3' Then
	     let v_trabajo = 'Pintar';
	  elif _trabajo = '4' Then
	     let v_trabajo = 'Reparar/Pintar';
	  end if

      if a_tamano = 'G' then
	  	if v_precio_grande = 0 and v_bloqueado = 1 Then
		   continue foreach;
		end if
		let _precio_char = 	v_precio_grande;
		let v_concat = Trim(v_desc_parte) || " " || trim(v_trabajo) || " " || trim(_precio_char);
		RETURN  v_no_parte,
				v_desc_parte,
				v_localizacion,
				v_trabajo,
				v_concat,
				v_precio_grande,
				v_bloqueado 
				WITH RESUME;
	  end if

      if a_tamano = 'M' then
	  	if v_precio_mediano = 0 and v_bloqueado = 1 Then
		   continue foreach;
		end if
		let _precio_char = 	v_precio_mediano;
		let v_concat = Trim(v_desc_parte) || " " || trim(v_trabajo) || " " || trim(_precio_char);
		RETURN  v_no_parte,
				v_desc_parte,
				v_localizacion,
				v_trabajo,
				v_concat,
				v_precio_mediano,
				v_bloqueado 
				WITH RESUME;
	  end if

      if a_tamano = 'C' then
	  	if v_precio_chico = 0  and v_bloqueado = 1 Then
		   continue foreach;
		end if
		let _precio_char = 	v_precio_chico;
		let v_concat = Trim(v_desc_parte) || " " || trim(v_trabajo) || " " || trim(_precio_char);
		RETURN  v_no_parte,
				v_desc_parte,
				v_localizacion,
				v_trabajo,
				v_concat,
				v_precio_chico,
				v_bloqueado 
				WITH RESUME;
	  end if

  END FOREACH

END FOREACH


	


END PROCEDURE;