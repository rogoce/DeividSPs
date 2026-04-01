-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe73;
 
create procedure sp_proe73(a_poliza CHAR(10), a_endoso CHAR(5), a_unidad CHAR(5), a_cobertura CHAR(5)) returning DECIMAL(5,2);

DEFINE _cod_producto  		CHAR(5);
DEFINE _acepta_desc   		SMALLINT;
DEFINE _descuento_max		DECIMAL(5,2);
DEFINE _tipo_descuento      SMALLINT;


SELECT cod_producto
  INTO _cod_producto
  FROM endeduni
 WHERE no_poliza = a_poliza
   AND no_endoso = a_endoso
   AND no_unidad = a_unidad;

LET _descuento_max = 0;
LET _tipo_descuento = 0;

SELECT prdcobpd.acepta_desc, descuento_max, tipo_descuento
  INTO _acepta_desc, _descuento_max, _tipo_descuento 
  FROM prdcobpd
 WHERE prdcobpd.cod_producto  = _cod_producto
   AND prdcobpd.cod_cobertura = a_cobertura;

If _acepta_desc = 1 Then
   if _tipo_descuento = 1 then	--> Descuento RC
		return _descuento_max;	
   elif _tipo_descuento = 2 then --> Descuento Combinado Casco
        let _descuento_max = sp_proe72(a_poliza,a_unidad);
		return _descuento_max;	
   end if
Else
   Return 0.00;
End If

end procedure
