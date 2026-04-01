--Creado por Armando Moreno M. 15/11/2017
--SI SE COLOCA VALOR DIFERENTE A CERO EN ARGUMENTO A_ACT, EL PROGRAMA ACTUALIZA LA DESCRIPCION QUE ESTA EN EL PRODUCTO POR COBERTURA
--A LA ULTIMA VIGENCIA DE LA POLIZA.

DROP PROCEDURE sp_arregla_desc_cob_emipocob;
CREATE PROCEDURE sp_arregla_desc_cob_emipocob(a_periodo1 char(7), a_periodo2 char(7), a_act smallint default 0)
RETURNING CHAR(20),char(10),char(5),char(5),char(10);


DEFINE _no_unidad		CHAR(5);
DEFINE _no_documento    char(20);
define _no_poliza       char(10);
define _cod_producto    char(5);
define _cod_cobertura	char(5);
define _desc_limite1c   varchar(50);
define _desc_limite2c   varchar(50);
define _desc_limite1p   varchar(50);
define _desc_limite2p	varchar(50);

SET ISOLATION TO DIRTY READ;

BEGIN

foreach
	select no_documento
	  into _no_documento
	  from emipomae
	 where actualizado = 1
	   and cod_ramo    = '020'
	   and cotizacion is not null
	   and periodo >= a_periodo1
	   and periodo <= a_periodo2
	   and estatus_poliza <> '2'
	   group by no_documento
	   order by no_documento
	   
    let _no_poliza = sp_sis21(_no_documento);
	
	foreach
		select no_unidad,
		       cod_producto
		  into _no_unidad,
               _cod_producto
		  from emipouni
         where no_poliza = _no_poliza

		let _desc_limite1c = null;
		let _desc_limite2c = null;
		foreach
			select cod_cobertura,
			       desc_limite1,
				   desc_limite2
			  into _cod_cobertura,
                   _desc_limite1c,
				   _desc_limite2c
			  from emipocob
             where no_poliza = _no_poliza
               and no_unidad = _no_unidad

			let _desc_limite1p = null;
			let _desc_limite2p = null;
			
			select desc_limite1,
			       desc_limite2
			  into _desc_limite1p,
			       _desc_limite2p
			  from prdcobpd
			 where cod_producto  = _cod_producto
               and cod_cobertura = _cod_cobertura;
			   
			if _desc_limite1p is null then
				continue foreach;
			end if
            if _desc_limite1c is null then
			  if a_act <> 0 then
			   update emipocob
				   set desc_limite1 = _desc_limite1p,
				       desc_limite2 = _desc_limite2p
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and cod_cobertura = _cod_cobertura;
			  end if	   
					   
				return _no_documento,_no_poliza,_no_unidad,_cod_producto,_cod_cobertura with resume;
			end if

		end foreach
	end foreach

end foreach	
END
END PROCEDURE;