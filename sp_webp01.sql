-- Procedimiento que se utuliza cuando se dispara el trigger. 
-- 
-- creado: 20/11/2024 - Autor: Federico Coronado

DROP PROCEDURE sp_webp01;
CREATE PROCEDURE "informix".sp_webp01()
REFERENCING OLD AS viejo NEW AS nuevo FOR ponderacion; 								  

DEFINE _descripcion         VARCHAR(255);
DEFINE _nombre_viejo        VARCHAR(10);
DEFINE _nombre_nuevo        VARCHAR(10);

select nombre
  into _nombre_viejo
  from cliriesgo
 where cod_riesgo = viejo.cod_riesgo;  

select nombre
  into _nombre_nuevo
  from cliriesgo
 where cod_riesgo = nuevo.cod_riesgo;

let _descripcion = "";

if ((viejo.cod_pep = nuevo.cod_pep and viejo.cod_producto = nuevo.cod_producto and viejo.cod_canal = nuevo.cod_canal and viejo.nacionalidad = nuevo.nacionalidad and viejo.cod_profesion = nuevo.cod_profesion and viejo.cod_actividad = nuevo.cod_actividad and viejo.cod_ocupacion = nuevo.cod_ocupacion and viejo.cod_categoria = nuevo.cod_categoria and viejo.pais_nacimiento = nuevo.pais_nacimiento 
    and viejo.origen_fondo = nuevo.origen_fondo and viejo.monto_ingreso = nuevo.monto_ingreso and viejo.prov_residencia = nuevo.prov_residencia and viejo.forma_pago = nuevo.forma_pago and viejo.frecuencia_pago = nuevo.frecuencia_pago and viejo.lista = nuevo.lista and viejo.pep = nuevo.pep and viejo.fundacion = nuevo.fundacion and viejo.asegurado = nuevo.asegurado 
	and viejo.beneficiario = nuevo.beneficiario and viejo.tercero = nuevo.tercero and viejo.anos_constitucion = nuevo.anos_constitucion and viejo.pais_residencia = nuevo.pais_residencia) and (viejo.cod_riesgo <> nuevo.cod_riesgo)) then  				 
	LET _descripcion = 'Cambio desde el disparador manual, ';
	LET _descripcion = _descripcion||'valor anterior: '||viejo.valor_ponderacion||' ('||_nombre_viejo||'), valor nuevo: '||nuevo.valor_ponderacion||' ('||_nombre_nuevo||') '|| nuevo.comentarios;
	Insert into ponbitacora (cod_cliente, cod_riesgo, valor_ponderacion, usuario, descripcion)
				 values (nuevo.cod_cliente,nuevo.cod_riesgo, nuevo.valor_ponderacion, nuevo.user_changed, _descripcion);
				 
else
	--Cuando se modifica el valor de pep
	If viejo.pep <> nuevo.pep Then
		LET _descripcion = 'Es cliente pep, ';
	End If 

	--Cuando se modifica el valor de Cliente es una Fundación, ONG o se encuentra en Zonas Francas
	If viejo.fundacion <> nuevo.fundacion Then
		LET _descripcion = _descripcion||'Es cliente fundación, ONG, zona franca, ';
	End If 

	--Cuando se modifica el valor de Cliente se encuentra en listas o noticias negativas
	If viejo.lista <> nuevo.lista Then
		LET _descripcion = _descripcion||'Es cliente en listas o noticias negativas, '; 
	End If

	--Cuando se modifica el valor del riesgo
	If viejo.cod_riesgo <> nuevo.cod_riesgo Then
		LET _descripcion = _descripcion||'Nuevo nivel de riesgo establecido, ';
	End If 

	if _descripcion <> '' then 
		let _descripcion = _descripcion||'valor anterior: '||viejo.valor_ponderacion||' ('||_nombre_viejo||'), valor nuevo: '||nuevo.valor_ponderacion||' ('||_nombre_nuevo||') ' || nuevo.comentarios;
		 
		Insert into ponbitacora (cod_cliente, cod_riesgo, valor_ponderacion, usuario, descripcion)
						 values (nuevo.cod_cliente,nuevo.cod_riesgo, nuevo.valor_ponderacion, nuevo.user_changed, _descripcion);
	end if	

end if
END PROCEDURE	