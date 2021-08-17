/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0.
 */

package software.amazon.smithy.swift.codegen.integration.steps

import software.amazon.smithy.codegen.core.Symbol
import software.amazon.smithy.swift.codegen.ClientRuntimeTypes
import software.amazon.smithy.swift.codegen.OperationStep

class OperationFinalizeStep(
    outputType: Symbol,
    outputErrorType: Symbol
) : OperationStep(outputType, outputErrorType) {
    override val inputType: Symbol = ClientRuntimeTypes.Http.SdkHttpRequestBuilder
}
