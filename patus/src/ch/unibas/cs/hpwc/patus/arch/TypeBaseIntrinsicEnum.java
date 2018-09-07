//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.1-b02-fcs 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2012.10.08 at 05:45:06 PM CEST 
//


package ch.unibas.cs.hpwc.patus.arch;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;


/**
 * <p>Java class for typeBaseIntrinsicEnum.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="typeBaseIntrinsicEnum">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *     &lt;enumeration value="barrier"/>
 *     &lt;enumeration value="threadid"/>
 *     &lt;enumeration value="numthreads"/>
 *     &lt;enumeration value="malloc"/>
 *     &lt;enumeration value="unary_plus"/>
 *     &lt;enumeration value="unary_minus"/>
 *     &lt;enumeration value="plus"/>
 *     &lt;enumeration value="minus"/>
 *     &lt;enumeration value="multiply"/>
 *     &lt;enumeration value="divide"/>
 *     &lt;enumeration value="fma"/>
 *     &lt;enumeration value="splat"/>
 *     &lt;enumeration value="fms"/>
 *     &lt;enumeration value="vector-reduce-sum"/>
 *     &lt;enumeration value="vector-reduce-product"/>
 *     &lt;enumeration value="vector-reduce-min"/>
 *     &lt;enumeration value="vector-reduce-max"/>
 *     &lt;enumeration value="load-gpr"/>
 *     &lt;enumeration value="store-gpr"/>
 *     &lt;enumeration value="load-fpr-aligned"/>
 *     &lt;enumeration value="load-fpr-unaligned"/>
 *     &lt;enumeration value="store-fpr-aligned"/>
 *     &lt;enumeration value="store-fpr-unaligned"/>
 *     &lt;enumeration value="min"/>
 *     &lt;enumeration value="max"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlEnum
public enum TypeBaseIntrinsicEnum {

    @XmlEnumValue("barrier")
    BARRIER("barrier"),
    @XmlEnumValue("threadid")
    THREADID("threadid"),
    @XmlEnumValue("numthreads")
    NUMTHREADS("numthreads"),
    @XmlEnumValue("malloc")
    MALLOC("malloc"),
    @XmlEnumValue("unary_plus")
    UNARY_PLUS("unary_plus"),
    @XmlEnumValue("unary_minus")
    UNARY_MINUS("unary_minus"),
    @XmlEnumValue("plus")
    PLUS("plus"),
    @XmlEnumValue("minus")
    MINUS("minus"),
    @XmlEnumValue("multiply")
    MULTIPLY("multiply"),
    @XmlEnumValue("divide")
    DIVIDE("divide"),
    @XmlEnumValue("fma")
    FMA("fma"),
    @XmlEnumValue("splat")
    SPLAT("splat"),
    @XmlEnumValue("fms")
    FMS("fms"),
    @XmlEnumValue("vector-reduce-sum")
    VECTOR_REDUCE_SUM("vector-reduce-sum"),
    @XmlEnumValue("vector-reduce-product")
    VECTOR_REDUCE_PRODUCT("vector-reduce-product"),
    @XmlEnumValue("vector-reduce-min")
    VECTOR_REDUCE_MIN("vector-reduce-min"),
    @XmlEnumValue("vector-reduce-max")
    VECTOR_REDUCE_MAX("vector-reduce-max"),
    @XmlEnumValue("load-gpr")
    LOAD_GPR("load-gpr"),
    @XmlEnumValue("store-gpr")
    STORE_GPR("store-gpr"),
    @XmlEnumValue("load-fpr-aligned")
    LOAD_FPR_ALIGNED("load-fpr-aligned"),
    @XmlEnumValue("load-fpr-unaligned")
    LOAD_FPR_UNALIGNED("load-fpr-unaligned"),
    @XmlEnumValue("store-fpr-aligned")
    STORE_FPR_ALIGNED("store-fpr-aligned"),
    @XmlEnumValue("store-fpr-unaligned")
    STORE_FPR_UNALIGNED("store-fpr-unaligned"),
    @XmlEnumValue("min")
    MIN("min"),
    @XmlEnumValue("max")
    MAX("max");
    private final String value;

    TypeBaseIntrinsicEnum(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static TypeBaseIntrinsicEnum fromValue(String v) {
        for (TypeBaseIntrinsicEnum c: TypeBaseIntrinsicEnum.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}