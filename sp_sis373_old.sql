create procedure "informix".sp_sis373(a_poliza CHAR(10), a_endoso CHAR(5))
 RETURNING CHAR(25), CHAR(20), integer,char(30);
--}
DEFINE _firma  CHAR(25);
DEFINE _ls_autoriza CHAR(20);
DEFINE _ls_cotizacion CHAR(10);
DEFINE _li_cotizacion int;
define _linea_rapida integer;
define _user_added char(10);
define _descripcion char(30);

--SET DEBUG FILE TO "sp_sis373.trc"; 
--trace on;


IF a_endoso <> '00000' THEN
    RETURN "","",0,"";
END IF

let _linea_rapida = 0;
let _descripcion = "";

FOREACH WITH HOLD
	SELECT cotizacion,
		   linea_rapida,
		   user_added
	  INTO _ls_cotizacion,
		   _linea_rapida,
		   _user_added
	  FROM emipomae
	 WHERE no_poliza = a_poliza
	   AND nueva_renov = 'N'

	LET _li_cotizacion = _ls_cotizacion;

	SELECT TRIM(userautoriza)
	  INTO _ls_autoriza
	  FROM wf_cotizacion
	 WHERE nrocotizacion = _li_cotizacion;

	SELECT firma
	  INTO _firma
	  FROM wf_firmas
	 WHERE usuario = _ls_autoriza;

    LET _firma = "C:\DEIVID\" || _firma;

-->** Se cambio para que traiga la firma del Sr. Chamorro -- 03/01/2008 **<--

	SELECT valor_parametro 
	  INTO _ls_autoriza
	  FROM inspaag
	 WHERE codigo_parametro = "firma_autorizada"; 

-->**<--

    IF _ls_autoriza IS NULL THEN
		LET _ls_autoriza = "";
    END IF

	if _linea_rapida = 1 then
		let _ls_autoriza = "VIELKAR";
		let _ls_autoriza = trim(_ls_autoriza);
		select descripcion
		  into _descripcion
		  from insuser
		 where usuario = _user_added;
		let _firma = trim(_user_added);
	end if

	if _descripcion is null then
		let _descripcion = "";
	end if
	RETURN _firma,
	       _ls_autoriza,
		   _linea_rapida,
		   _descripcion
		   WITH RESUME;

END FOREACH
end procedure                                                                                                                                       
